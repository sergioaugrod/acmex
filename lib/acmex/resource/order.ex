defmodule Acmex.Resource.Order do
  @moduledoc """
  This structure represents a client request for a certificate.
  """

  alias Acmex.Request

  @enforce_keys ~w(
    authorizations
    certificate
    expires
    finalize
    identifiers
    status
    url
  )a

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          authorizations: [String.t()],
          certificate: String.t(),
          expires: String.t(),
          finalize: String.t(),
          identifiers: [%{type: String.t(), value: String.t()}],
          status: String.t(),
          url: String.t()
        }

  @doc """
  Builds an order struct.
  """
  @spec new(map(), keyword()) :: t()
  def new(order, headers \\ []) do
    url =
      case Request.get_header(headers, "Location") do
        nil -> order[:url]
        location -> location
      end

    struct(__MODULE__, Map.put(order, :url, url))
  end
end
