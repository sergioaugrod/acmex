defmodule Acmex.Resource.OrderTest do
  use ExUnit.Case, async: true

  alias Acmex.Resource.Order
  alias Acmex.Request

  setup_all do
    {:ok, order} = Acmex.new_order(["example.com"])

    [order: order]
  end

  describe "Order.new/2" do
    test "returns order struct", %{order: order} do
      {:ok, resp} = Request.get(order.url)

      order = Order.new(resp.body, resp.headers)

      assert order.__struct__ == Order
      assert order.status == "pending"
    end
  end

  describe "Order.reload/1" do
    test "returns updated order", %{order: order} do
      {:ok, order} = Order.reload(order)

      assert order.status == "pending"
    end

    test "returns error because order url is invalid", %{order: order} do
      directory_url = Application.get_env(:acmex, :directory_url)
      order = %{order | url: "#{directory_url}/my-order/mGxR5"}

      assert {:error, _} = Order.reload(order)
    end
  end
end
