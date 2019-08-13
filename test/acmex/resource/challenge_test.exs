defmodule Acmex.Resource.ChallengeTest do
  use ExUnit.Case, async: true

  alias Acmex.Crypto
  alias Acmex.Resource.{Authorization, Challenge}

  setup_all do
    {:ok, order} = Acmex.new_order(["example.com"])
    authorization = List.first(order.authorizations)

    [challenge: Authorization.http(authorization)]
  end

  describe "Challenge.new/1" do
    test "returns challenge struct" do
      attrs = %{
        status: "pending",
        token: "80ec4664-ca5b-11e8-a4c8-02425707000b",
        type: "http-01",
        url: nil
      }

      challenge = Challenge.new(attrs)

      assert challenge.__struct__ == Challenge
      assert challenge.type == "http-01"
    end
  end

  describe "Challenge.get_response/2" do
    test "returns challenge response", %{challenge: challenge} do
      jwk = Crypto.get_jwk("test/support/fixture/account.key")

      {:ok, response} = Challenge.get_response(challenge, jwk)

      assert String.length(response) == 87
    end
  end

  describe "Challenge.get_key_authorization/2" do
    test "returns challenge key authorization", %{challenge: challenge} do
      jwk = Crypto.get_jwk("test/support/fixture/account.key")

      {:ok, authorization} = Challenge.get_key_authorization(challenge, jwk)

      assert String.length(authorization) == 87
    end
  end
end
