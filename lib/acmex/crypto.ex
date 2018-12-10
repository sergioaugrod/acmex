defmodule Acmex.Crypto do
  @moduledoc false

  alias JOSE.{JWK, JWS}

  def get_jwk(keyfile) do
    keyfile
    |> JWK.from_pem_file()
    |> JWK.to_map()
  end

  def sign(jwk, payload, %{"kid" => _kid} = header) do
    jwk
    |> JWS.sign(payload, Map.put(header, "alg", "RS256"))
    |> elem(1)
  end

  def sign(jwk, payload, header) do
    {_, public_jwk} = JWK.to_public_map(jwk)

    jwk
    |> JWS.sign(payload, Map.merge(header, %{"alg" => "RS256", "jwk" => public_jwk}))
    |> elem(1)
  end
end
