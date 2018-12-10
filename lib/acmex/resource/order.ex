defmodule Acmex.Resource.Order do
  @moduledoc """
  This structure represents a client request for a certificate.
  """

  alias Acmex.Request
  alias Acmex.Resource.Authorization

  defstruct [
    :authorizations,
    :certificate,
    :expires,
    :finalize,
    :identifiers,
    :status,
    :url
  ]

  def new(%{authorizations: authorizations} = order, headers \\ []) do
    order = %{order | authorizations: Enum.map(authorizations, &new_authorization(&1))}

    url =
      case Request.get_header(headers, "Location") do
        nil -> order[:url]
        location -> location
      end

    struct(__MODULE__, Map.put(order, :url, url))
  end

  def reload(%__MODULE__{url: url}) do
    case Request.get(url) do
      {:ok, resp} -> {:ok, __MODULE__.new(Map.put(resp.body, :url, url))}
      error -> error
    end
  end

  defp new_authorization(url), do: Authorization.new(fetch_authorization(url))

  defp fetch_authorization(url) do
    {:ok, resp} = Request.get(url)
    resp.body
  end
end
