defmodule Acmex.Resource.AccountTest do
  use ExUnit.Case, async: true

  alias Acmex.Resource.Account

  describe "new/1" do
    test "returns an account struct" do
      attrs = %{
        contact: ["mailto:info@example.com"],
        url: "http://localhost:14000/acme/acct/1",
        status: "valid"
      }

      assert %Account{
               contact: ["mailto:info@example.com"],
               status: "valid",
               url: "http://localhost:14000/acme/acct/1"
             } = Account.new(attrs)
    end
  end
end
