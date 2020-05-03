defmodule Acmex.Support.Order do
  @moduledoc false

  alias Acmex.{OpenSSL, Resource.Authorization}

  def create(_, domains \\ generate_random_domains())

  def create("finalized", domains) do
    %{order: order} = create("valid", domains)

    private_key = OpenSSL.generate_key(:rsa)
    {:ok, csr} = OpenSSL.generate_csr(private_key, domains)

    {:ok, order} = Acmex.finalize_order(order, csr)

    order = poll_order_status(order)

    %{order: order, domains: domains}
  end

  def create("valid", domains) do
    {:ok, order} = Acmex.new_order(domains)

    Enum.each(order.authorizations, fn authorization ->
      challenge = Authorization.http(authorization)
      Acmex.validate_challenge(challenge)
    end)

    order = poll_order_status(order, "ready")

    %{domains: domains, order: order}
  end

  def generate_random_domains(quantity \\ Enum.random(1..5)),
    do: Enum.map(1..quantity, fn _ -> generate_random_domain() end)

  defp generate_random_domain do
    name =
      15
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64(padding: false)
      |> String.replace("_", "-")

    "#{name}#{:os.system_time(:seconds)}.com"
  end

  defp poll_order_status(order, status \\ "valid") do
    case Acmex.get_order(order.url) do
      {:ok, %{status: ^status} = order} -> order
      {:ok, order} -> poll_order_status(order)
    end
  end
end
