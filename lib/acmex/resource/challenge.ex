defmodule Acmex.Resource.Challenge do
  @moduledoc """
  This structure represents a challenge to prove control of an identifier.
  """

  alias Acmex.Request
  alias JOSE.JWK

  defstruct [
    :status,
    :token,
    :type,
    :url
  ]

  def new(challenge), do: struct(__MODULE__, challenge)

  def reload(%__MODULE__{url: url}) do
    case Request.get(url) do
      {:ok, resp} -> {:ok, __MODULE__.new(resp.body)}
      error -> error
    end
  end

  def get_response(%__MODULE__{type: "http-01"} = challenge, jwk),
    do: get_key_authorization(challenge, jwk)

  def get_key_authorization(%__MODULE__{token: token}, jwk),
    do: {:ok, "#{token}.#{JWK.thumbprint(jwk)}"}
end
