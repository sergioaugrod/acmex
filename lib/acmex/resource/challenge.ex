defmodule Acmex.Resource.Challenge do
  @moduledoc """
  This structure represents a challenge to prove control of an identifier.
  """

  alias JOSE.JWK

  @enforce_keys [:status, :token, :type, :url]

  defstruct @enforce_keys

  @type t :: %__MODULE__{status: String.t(), token: String.t(), type: String.t(), url: String.t()}
  @type dns_response :: %{
          key_authorization: String.t(),
          record_name: String.t(),
          record_type: String.t()
        }
  @type http_response :: %{
          content_type: String.t(),
          filename: String.t(),
          key_authorization: String.t()
        }

  @spec new(map()) :: __MODULE__.t()
  def new(challenge), do: struct(__MODULE__, challenge)

  @spec get_response(__MODULE__.t(), map()) :: {:ok, dns_response()} | {:ok, http_response()}
  def get_response(%__MODULE__{type: "dns-01"} = challenge, jwk) do
    {:ok, key_authorization} = get_key_authorization(challenge, jwk)

    key_authorization =
      :sha256
      |> :crypto.hash(key_authorization)
      |> Base.url_encode64(padding: false)

    {:ok,
     %{
       record_name: "_acme-challenge",
       record_type: "TXT",
       key_authorization: key_authorization
     }}
  end

  def get_response(%__MODULE__{} = challenge, jwk) do
    {:ok, key_authorization} = get_key_authorization(challenge, jwk)

    {:ok,
     %{
       key_authorization: key_authorization,
       filename: ".well-known/acme-challenge/#{key_authorization}",
       content_type: "text/plain"
     }}
  end

  def get_key_authorization(%__MODULE__{token: token}, jwk),
    do: {:ok, "#{token}.#{JWK.thumbprint(jwk)}"}
end
