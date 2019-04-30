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
      {:ok, response} = Request.head(directory.new_nonce)
      nonce = Request.get_header(response.headers, "Replay-Nonce")
      {:ok, jwk} = Crypto.fetch_jwk_from_file("test/support/fixture/account.key")

      [directory: directory, jwk: jwk, nonce: nonce]
    end

    test "returns response", %{directory: directory, jwk: jwk, nonce: nonce} do
      payload = %{contact: ["mailto:info@example.com"], termsOfServiceAgreed: true}

      {:ok, response} = Request.post(directory.new_account, jwk, payload, nonce)

      assert response.status_code == 200
      assert response.body.status == "valid"
      assert Request.get_header(response.headers, "Location")
    end
  end

  describe "Request.head/1" do
    test "returns nonce response", %{directory: directory} do
      {:ok, response} = Request.head(directory.new_nonce)

      assert response.body == ""
      assert response.status_code == 204
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
