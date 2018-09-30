defmodule Acmex.Resource.Order do
  alias Acmex.Request
  alias Acmex.Resource.Authorization

  defstruct [
    :authorizations,
    :certificate,
    :expires,
    :finalize,
    :identifiers,
    :status
  ]

  def new(%{authorizations: authorizations} = order) do
    order = %{order | authorizations: Enum.map(authorizations, &new_authorization(&1))}
    struct(__MODULE__, order)
  end

  defp new_authorization(url), do: Authorization.new(fetch_authorization(url))

  defp fetch_authorization(url) do
    {:ok, resp} = Request.get(url)
    resp.body
  end
end
