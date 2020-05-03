defmodule Acmex.Resource.ChallengeTest do
  use ExUnit.Case, async: true

  alias Acmex.Crypto
  alias Acmex.Resource.{Authorization, Challenge}

  setup_all do
    {:ok, order} = Acmex.new_order(["example-challenge-test.com"])
    authorization = List.first(order.authorizations)

    {:ok,
     dns_challenge: Authorization.dns(authorization),
     http_challenge: Authorization.http(authorization)}
  end

  describe "new/1" do
    test "returns a challenge struct" do
      attrs = %{
        status: "pending",
        token: "80ec4664",
        type: "http-01",
        url: nil
      }

      assert %Challenge{status: "pending", token: "80ec4664", type: "http-01", url: nil} =
               Challenge.new(attrs)
    end
  end

  describe "get_response/2" do
    test "when type is HTTP, returns the HTTP challenge response", %{http_challenge: challenge} do
      {:ok, jwk} = Crypto.fetch_jwk_from_key(File.read!("test/support/fixture/account.key"))

      {:ok, response} = Challenge.get_response(challenge, jwk)

      assert String.length(response.key_authorization) == 87
      assert response.content_type == "text/plain"
      assert response.filename == ".well-known/acme-challenge/#{challenge.token}"
    end

    test "when type is DNS, returns the DNS challenge response", %{dns_challenge: challenge} do
      {:ok, jwk} = Crypto.fetch_jwk_from_key(File.read!("test/support/fixture/account.key"))

      {:ok, response} = Challenge.get_response(challenge, jwk)

      assert String.length(response.key_authorization) == 43
      assert response.record_name == "_acme-challenge"
      assert response.record_type == "TXT"
    end
  end

  describe "get_key_authorization/2" do
    test "returns the challenge key authorization", %{http_challenge: challenge} do
      {:ok, jwk} = Crypto.fetch_jwk_from_key(File.read!("test/support/fixture/account.key"))

      {:ok, authorization} = Challenge.get_key_authorization(challenge, jwk)

      assert String.length(authorization) == 87
    end
  end
end
