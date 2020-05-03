defmodule Acmex.Resource.AuthorizationTest do
  use ExUnit.Case, async: true

  alias Acmex.Resource.{Authorization, Challenge}
  alias Acmex.Support.Order

  setup_all do
    {:ok, order} =
      1
      |> Order.generate_random_domains()
      |> Acmex.new_order()

    {:ok, authorization: List.first(order.authorizations)}
  end

  describe "new/1" do
    test "returns an authorization struct" do
      attrs = %{
        challenges: [
          %{
            status: "pending",
            token: "123",
            type: "http-01",
            url: "https://localhost:14000/chalZ/123"
          }
        ],
        expires: "2020-04-26T19:48:16Z",
        identifier: %{type: "dns", value: "example11587926896.com"},
        status: "pending"
      }

      assert %Authorization{
               challenges: [
                 %Challenge{
                   status: "pending",
                   token: "123",
                   type: "http-01",
                   url: "https://localhost:14000/chalZ/123"
                 }
               ],
               expires: "2020-04-26T19:48:16Z",
               identifier: %{type: "dns", value: "example11587926896.com"},
               status: "pending"
             } = Authorization.new(attrs)
    end
  end

  describe "http/1" do
    test "returns the HTTP challenge", %{authorization: authorization} do
      assert %Challenge{type: "http-01"} = Authorization.http(authorization)
    end
  end

  describe "dns/1" do
    test "returns the DNS challenge", %{authorization: authorization} do
      assert %Challenge{type: "dns-01"} = Authorization.dns(authorization)
    end
  end
end
