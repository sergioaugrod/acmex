defmodule Acmex.Resource.AuthorizationTest do
  use ExUnit.Case, async: true

  alias Acmex.Resource.Authorization

  setup_all do
    {:ok, order} = Acmex.new_order(["example1#{:os.system_time(:seconds)}.com"])

    [authorization: List.first(order.authorizations)]
  end

  describe "Authorization.http/1" do
    test "returns the http challenge", %{authorization: authorization} do
      challenge = Authorization.http(authorization)

      assert challenge.type == "http-01"
      assert challenge.status == "pending"
      assert challenge.token
    end
  end

  describe "Authorization.dns/1" do
    test "returns the dns challenge", %{authorization: authorization} do
      challenge = Authorization.dns(authorization)

      assert challenge.type == "dns-01"
      assert challenge.status == "pending"
      assert challenge.token
    end
  end
end
