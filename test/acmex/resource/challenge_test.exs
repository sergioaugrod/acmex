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

  describe "Challenge.reload/1" do
    test "returns updated challenge", %{challenge: challenge} do
      {:ok, challenge} = Challenge.reload(challenge)

      assert challenge.status == "pending"
    end

    test "returns error because challenge url is invalid", %{challenge: challenge} do
      directory_url = Application.get_env(:acmex, :directory_url)
      challenge = %{challenge | url: "#{directory_url}/chalZ/mGxR5"}

      assert {:error, _} = Challenge.reload(challenge)
    end
  end

  describe "Challenge.get_response/2" do
    test "returns challenge response", %{challenge: challenge} do
      jwk = Crypto.get_jwk("test/support/fixture/account.key")
      assert String.length(Challenge.get_response(challenge, jwk)) == 87
    end
  end

  describe "Challenge.get_key_authorization/2" do
    test "returns challenge key authorization", %{challenge: challenge} do
      jwk = Crypto.get_jwk("test/support/fixture/account.key")
      assert String.length(Challenge.get_key_authorization(challenge, jwk)) == 87
    end
  end
end
