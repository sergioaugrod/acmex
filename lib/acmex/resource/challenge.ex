defmodule Acmex.Resource.Challenge do
  alias JOSE.JWK

  defstruct [
    :status,
    :token,
    :type,
    :url
  ]

  def get_response(%__MODULE__{type: "http-01"} = challenge, jwk),
    do: get_key_authorization(challenge, jwk)

  def get_key_authorization(%__MODULE__{token: token}, jwk),
    do: "#{token}.#{JWK.thumbprint(jwk)}"
end
