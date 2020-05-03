defmodule Acmex.RequestTest do
  use ExUnit.Case, async: true

  alias Acmex.{Config, Request, Support}
  alias Acmex.Resource.Directory

  setup_all do
    directory = Directory.new() |> elem(1)

    {:ok, directory: directory, directory_url: Config.directory_url()}
  end

  describe "get/3" do
    test "returns the response", %{directory_url: directory_url} do
      assert {:ok, response} = Request.get(directory_url, [], nil)

      assert is_binary(response.body)
    end

    test "returns the response with encoded body", %{
      directory: %{new_account: new_account},
      directory_url: directory_url
    } do
      assert {:ok, %{body: %{newAccount: ^new_account}}} = Request.get(directory_url, [])
    end
  end

  describe "post/5" do
    setup %{directory: %{new_nonce: new_nonce}} do
      get_nonce = fn ->
        {:ok, response} = Request.head(new_nonce)

        Request.get_header(response.headers, "Replay-Nonce")
      end

      {:ok, get_nonce: get_nonce, jwk: Support.Account.jwk()}
    end

    test "returns the response", %{directory: directory, get_nonce: get_nonce, jwk: jwk} do
      payload = %{contact: ["mailto:info@example.com"], termsOfServiceAgreed: true}

      post = fn post, directory_new_account, jwk, payload, nonce ->
        case Request.post(directory_new_account, jwk, payload, nonce) do
          {:ok, _} = result ->
            result

          {:error, _response} ->
            nonce = get_nonce.()
            post.(post, directory_new_account, jwk, payload, nonce)
        end
      end

      nonce = get_nonce.()

      assert {:ok, %{body: %{status: "valid"}, headers: headers, status_code: 200}} =
               post.(post, directory.new_account, jwk, payload, nonce)

      assert Request.get_header(headers, "Location")
    end
  end

  describe "post_as_get/5" do
    setup %{directory: directory} do
      get_nonce = fn ->
        {:ok, response} = Request.head(directory.new_nonce)
        Request.get_header(response.headers, "Replay-Nonce")
      end

      {:ok, %{url: kid}} = Acmex.get_account()
      {:ok, order} = Acmex.new_order(["example1.com"])

      {:ok, get_nonce: get_nonce, jwk: Support.Account.jwk(), kid: kid, order: order}
    end

    test "returns the response", %{get_nonce: get_nonce, jwk: jwk, kid: kid, order: order} do
      post_as_get = fn post_as_get, order_url, jwk, nonce, kid ->
        case Request.post_as_get(order_url, jwk, nonce, kid) do
          {:ok, _response} = result ->
            result

          {:error, _response} ->
            nonce = get_nonce.()
            post_as_get.(post_as_get, order_url, jwk, nonce, kid)
        end
      end

      nonce = get_nonce.()

      assert {:ok, %{body: %{status: "pending"}, status_code: 200}} =
               post_as_get.(post_as_get, order.url, jwk, nonce, kid)
    end
  end

  describe "head/1" do
    test "returns a nonce response", %{directory: %{new_nonce: new_nonce}} do
      assert {:ok, %{body: "", status_code: 200, headers: headers}} = Request.head(new_nonce)

      assert Request.get_header(headers, "Replay-Nonce")
    end
  end

  describe "get_header/2" do
    test "returns the value of header" do
      headers = [
        {"Foo", "Bar"},
        {"X-Request-ID", "1234abc"}
      ]

      assert Request.get_header(headers, "Foo") == "Bar"
    end
  end
end
