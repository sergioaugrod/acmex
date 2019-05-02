defmodule Acmex.Resource.OrderTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok, order} = Acmex.new_order(["example.com"])

    [order: order]
  end
end
