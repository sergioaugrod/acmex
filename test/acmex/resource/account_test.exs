defmodule Acmex.Resource.AccountTest do
  use ExUnit.Case, async: true

  alias Acmex.Resource.Account

  describe "Account.new/1" do
    test "returns account struct" do
      attrs = %{
        agreement: nil,
        contact: ["mailto:info@example.com"],
        created_at: nil,
        id: 313120931,
        status: "valid"
      }

      account = Account.new(attrs)

      assert account.__struct__ == Account
      assert account.status == "valid"
    end
  end
end
