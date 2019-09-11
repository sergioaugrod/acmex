defmodule Acmex.Resource.Challenge do
  @moduledoc """
  This structure represents a challenge to prove control of an identifier.
  """

  alias JOSE.JWK

  @enforce_keys [:status, :token, :type, :url]

  defstruct @enforce_keys

  @type t :: %__MODULE__{status: String.t(), token: String.t(), type: String.t(), url: String.t()}

  @spec new(map()) :: __MODULE__.t()
  def new(challenge), do: struct(__MODULE__, challenge)

  @spec get_response(__MODULE__.t(), map()) :: {:ok, String.t()}
  def get_response(%__MODULE__{type: "http-01"} = challenge, jwk),
    do: get_key_authorization(challenge, jwk)

  def get_key_authorization(%__MODULE__{token: token}, jwk),
    do: {:ok, "#{token}.#{JWK.thumbprint(jwk)}"}
end
