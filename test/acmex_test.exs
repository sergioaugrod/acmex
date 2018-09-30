defmodule AcmexTest do
  use ExUnit.Case, async: true

  alias Acmex.Resource.{Account, Authorization}

  setup_all do
    Acmex.start_link("test/support/fixture/account.key")
    Acmex.new_account(["mailto:info@example.com"], true)
    :ok
  end

  describe "Acmex.new_account/2" do
    test "creates a new account" do
      {:ok, account} = Acmex.new_account(["mailto:info@example.com"], true)

      assert account == %Account{
               agreement: nil,
               contact: ["mailto:info@example.com"],
               created_at: nil,
               id: nil,
               status: "valid",
               url: "https://localhost:14000/my-account/1"
             }
    end
  end

  describe "Acmex.get_account/0" do
    test "returns current account" do
      {:ok, account} = Acmex.get_account()

      assert account == %Account{
               agreement: nil,
               contact: ["mailto:info@example.com"],
               created_at: nil,
               id: nil,
               status: "valid",
               url: "https://localhost:14000/my-account/1"
             }
    end
  end

  describe "Acmex.new_order/1" do
    test "creates a new order" do
      {:ok, order} = Acmex.new_order(["example.com"])

      assert order.status == "pending"
      assert length(order.authorizations) == 1
    end
  end

  describe "Acmex.get_challenge_response/1" do
    test "returns the challenge authorization key" do
      {:ok, order} = Acmex.new_order(["example.com"])
      authorization = List.first(order.authorizations)
      challenge = Authorization.http(authorization)

      assert String.length(Acmex.get_challenge_response(challenge)) == 87
    end
  end

  describe "Acmex.validate_challenge/1" do
    test "validates a challenge" do
      {:ok, order} = Acmex.new_order(["example.com"])
      authorization = List.first(order.authorizations)
      challenge = Authorization.http(authorization)

      {:ok, challenge} = Acmex.validate_challenge(challenge)

      assert challenge.status == "pending"
      assert challenge.token
      assert challenge.type
      assert challenge.url
    end
  end

  describe "Acmex.finalize_order/2" do
  end

  describe "Acmex.get_certificate/1" do
  end
end
