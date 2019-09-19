defmodule Acmex.RequestTest do
  use ExUnit.Case, async: true

  alias Acmex.{Config, Crypto, Request}
  alias Acmex.Resource.Directory

  setup_all do
    [directory: elem(Directory.new(), 1), directory_url: Config.directory_url()]
  end

  describe "Request.get/3" do
    test "returns response", %{directory_url: directory_url} do
      {:ok, response} = Request.get(directory_url, [], nil)

      assert is_binary(response.body)
    end

    test "returns response with encoded body", %{
      directory: directory,
      directory_url: directory_url
    } do
      {:ok, response} = Request.get(directory_url, [])

      assert response.body.newAccount == directory.new_account
    end
  end

  describe "Request.post/5" do
    setup %{directory: directory} do
      get_nonce = fn ->
        {:ok, response} = Request.head(directory.new_nonce)
        Request.get_header(response.headers, "Replay-Nonce")
      end

      {:ok, jwk} = Crypto.fetch_jwk_from_key(File.read!("test/support/fixture/account.key"))

      [directory: directory, jwk: jwk, get_nonce: get_nonce]
    end

    test "returns response", %{directory: directory, jwk: jwk, get_nonce: get_nonce} do
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

      {:ok, response} = post.(post, directory.new_account, jwk, payload, nonce)

      assert response.status_code == 200
      assert response.body.status == "valid"
      assert Request.get_header(response.headers, "Location")
    end
  end

  describe "Request.post_as_get/5" do
    setup %{directory: directory} do
      get_nonce = fn ->
        {:ok, response} = Request.head(directory.new_nonce)
        Request.get_header(response.headers, "Replay-Nonce")
      end

      {:ok, jwk} = Crypto.fetch_jwk_from_key(File.read!("test/support/fixture/account.key"))
      {:ok, %{url: kid}} = Acmex.get_account()
      {:ok, order} = Acmex.new_order(["example1.com"])

      [order: order, jwk: jwk, get_nonce: get_nonce, kid: kid]
    end

    test "returns response", %{order: order, jwk: jwk, get_nonce: get_nonce, kid: kid} do
      post_as_get = fn post_as_get, order_url, jwk, nonce, kid ->
        case Request.post_as_get(order_url, jwk, nonce, kid) do
          {:ok, _} = result ->
            result

          {:error, _response} ->
            nonce = get_nonce.()
            post_as_get.(post_as_get, order_url, jwk, nonce, kid)
        end
      end

      nonce = get_nonce.()

      {:ok, response} = post_as_get.(post_as_get, order.url, jwk, nonce, kid)

      assert response.status_code == 200
      assert response.body.status == "pending"
    end
  end

  describe "Request.head/1" do
    test "returns nonce response", %{directory: directory} do
      {:ok, response} = Request.head(directory.new_nonce)

      assert response.body == ""
      assert response.status_code == 200
      assert Request.get_header(response.headers, "Replay-Nonce")
    end
  end

  describe "Request.get_header/2" do
    test "returns value of header" do
      headers = [
        {"Foo", "Bar"},
        {"X-Request-ID", "1234abc"}
      ]

      assert Request.get_header(headers, "Foo") == "Bar"
    end
  end
end
