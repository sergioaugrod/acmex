defmodule Acmex.CryptoTest do
  use ExUnit.Case, async: true

  alias Acmex.Crypto
  alias JOSE.JWK
  alias JOSE.JWS

  describe "Crypto.get_jwk/1" do
    test "returns jwk" do
      jwk = Crypto.get_jwk("test/support/fixture/account.key")
      assert JWK.thumbprint(jwk) == "5zmJUVWaucybUNJSLeCaO9D_cauS5QiwA92KTiY_vNc"
    end
  end

  describe "Crypto.sign/3" do
    setup do
      [jwk: Crypto.get_jwk("test/support/fixture/account.key")]
    end

    test "signs a payload with a header without kid", %{jwk: jwk} do
      headers = %{
        "nonce" => "pWLyWhyg4W8tIYppfoxX0w",
        "url" => "https://localhost:14000/sign-me-up"
      }

      body = %{termsOfServiceAgreed: true, contact: ["mailto:info@example.com"]}

      jws = Crypto.sign(jwk, Jason.encode!(body), headers)
      protected = Jason.decode!(JWS.peek_protected(jws))

      assert protected["alg"] == "RS256"
      assert protected["url"] == "https://localhost:14000/sign-me-up"
      assert protected["nonce"] == "pWLyWhyg4W8tIYppfoxX0w"
    end

    test "signs a payload with a header with kid", %{jwk: jwk} do
      headers = %{
        "nonce" => "pWLyWhyg4W8tIYppfoxX0w",
        "url" => "https://localhost:14000/sign-me-up",
        "kid" => "https://localhost:14000/my-account/1"
      }

      body = %{termsOfServiceAgreed: true, contact: ["mailto:info@example.com"]}

      jws = Crypto.sign(jwk, Jason.encode!(body), headers)
      protected = Jason.decode!(JWS.peek_protected(jws))

      assert protected["alg"] == "RS256"
      assert protected["url"] == "https://localhost:14000/sign-me-up"
      assert protected["nonce"] == "pWLyWhyg4W8tIYppfoxX0w"
      assert protected["kid"] == "https://localhost:14000/my-account/1"
    end
  end
end
