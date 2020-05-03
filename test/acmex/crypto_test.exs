defmodule Acmex.CryptoTest do
  use ExUnit.Case, async: true

  alias Acmex.{Crypto, Support}
  alias JOSE.{JWK, JWS}

  describe "fetch_jwk_from_key/1" do
    test "returns the JWK" do
      account_key = File.read!("test/support/fixture/account.key")

      {:ok, jwk} = Crypto.fetch_jwk_from_key(account_key)

      assert JWK.thumbprint(jwk) == "5zmJUVWaucybUNJSLeCaO9D_cauS5QiwA92KTiY_vNc"
    end

    test "when key is invalid, returns an error" do
      assert {:error, "invalid key"} = Crypto.fetch_jwk_from_key("123")
    end
  end

  describe "sign/3" do
    setup do
      {:ok, jwk: Support.Account.jwk()}
    end

    test "signs a payload with a header without kid", %{jwk: jwk} do
      headers = %{
        "nonce" => "pWLyWhyg4W8tIYppfoxX0w",
        "url" => "https://localhost:14000/sign-me-up"
      }

      encoded_body =
        Jason.encode!(%{termsOfServiceAgreed: true, contact: ["mailto:info@example.com"]})

      jws = Crypto.sign(jwk, encoded_body, headers)

      protected_jws =
        jws
        |> JWS.peek_protected()
        |> Jason.decode!()

      assert protected_jws["alg"] == "RS256"
      assert protected_jws["url"] == "https://localhost:14000/sign-me-up"
      assert protected_jws["nonce"] == "pWLyWhyg4W8tIYppfoxX0w"
    end

    test "signs a payload with a header with kid", %{jwk: jwk} do
      headers = %{
        "nonce" => "pWLyWhyg4W8tIYppfoxX0w",
        "url" => "https://localhost:14000/sign-me-up",
        "kid" => "https://localhost:14000/my-account/1"
      }

      encoded_body =
        Jason.encode!(%{termsOfServiceAgreed: true, contact: ["mailto:info@example.com"]})

      jws = Crypto.sign(jwk, encoded_body, headers)

      protected_jws =
        jws
        |> JWS.peek_protected()
        |> Jason.decode!()

      assert protected_jws["alg"] == "RS256"
      assert protected_jws["url"] == "https://localhost:14000/sign-me-up"
      assert protected_jws["nonce"] == "pWLyWhyg4W8tIYppfoxX0w"
      assert protected_jws["kid"] == "https://localhost:14000/my-account/1"
    end
  end
end
