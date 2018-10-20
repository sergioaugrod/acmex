defmodule Acmex.RequestTest do
  use ExUnit.Case, async: true

  alias Acmex.Crypto
  alias Acmex.Request

  describe "Request.get/3" do
    test "returns response" do
      {:ok, response} = Request.get("https://localhost:14000/dir", [], nil)

      assert is_binary(response.body)
    end

    test "returns response with encoded body" do
      {:ok, response} = Request.get("https://localhost:14000/dir", [])

      assert response.body.newAccount == "https://localhost:14000/sign-me-up"
    end
  end

  describe "Request.post/5" do
    setup do
      {:ok, response} = Request.head("https://localhost:14000/nonce-plz")
      nonce = Request.get_header(response.headers, "Replay-Nonce")
      jwk = Crypto.get_jwk("test/support/fixture/account.key")

      [jwk: jwk, nonce: nonce]
    end

    test "returns response", %{jwk: jwk, nonce: nonce} do
      url = "https://localhost:14000/sign-me-up"
      payload = %{contact: ["mailto:info@example.com"], termsOfServiceAgreed: true}

      {:ok, response} = Request.post(url, jwk, payload, nonce)

      assert response.status_code == 200
      assert response.body.status == "valid"
      assert Request.get_header(response.headers, "Location")
    end
  end

  describe "Request.head/1" do
    test "returns nonce response" do
      {:ok, response} = Request.head("https://localhost:14000/nonce-plz")

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
