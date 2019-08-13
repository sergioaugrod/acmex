defmodule Acmex.Resource.Order do
  @moduledoc """
  This structure represents a client request for a certificate.
  """

  alias Acmex.Request

  defstruct [
    :authorizations,
    :certificate,
    :expires,
    :finalize,
    :identifiers,
    :status,
    :url
  ]

  def new(order, headers \\ []) do
    url =
      case Request.get_header(headers, "Location") do
        nil -> order[:url]
        location -> location
      end

    struct(__MODULE__, Map.put(order, :url, url))
  end
end
