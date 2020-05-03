defmodule Acmex.Resource.OrderTest do
  use ExUnit.Case, async: true

  alias Acmex.Resource.Order

  describe "new/2" do
    test "returns an order struct" do
      attrs = %{
        authorizations: [
          "https://localhost:14000/authZ/_6qPZ3Qv9fmwfyvOvu9Y0telWauC77gby35KYmBPvGw"
        ],
        expires: "2019-08-15T01:35:30Z",
        finalize:
          "https://localhost:14000/finalize-order/KGLHqFBci4gsEpKlPAIIW6jg_zTriQmxSA5Zh6q6pFc",
        identifiers: [%{type: "dns", value: "example.com"}],
        status: "ready"
      }

      url = "http://sample.com"
      headers = [{"Location", url}]

      assert %Order{status: "ready", url: ^url} = Order.new(attrs, headers)
    end
  end
end
