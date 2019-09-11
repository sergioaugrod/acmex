defmodule Acmex.Crypto do
  @moduledoc false

  alias JOSE.{JWK, JWS}

  def fetch_jwk_from_key(key) do
    {:ok,
     key
     |> JWK.from_pem()
     |> JWK.to_map()}
  rescue
    _ -> {:error, "invalid key"}
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
