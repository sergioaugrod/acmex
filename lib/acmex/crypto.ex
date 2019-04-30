defmodule Acmex.Crypto do
  @moduledoc false

  alias JOSE.{JWK, JWS}

  def fetch_jwk_from_file(keyfile) do
    try do
      {:ok,
       keyfile
       |> JWK.from_pem_file()
       |> JWK.to_map()}
    rescue
      _ -> {:error, :invalid_jwk}
    end
  end

  def fetch_jwk(pem) do
    try do
      {%{kty: _}, jwk} = pem |> JOSE.JWK.from_pem() |> JOSE.JWK.to_map()
      {:ok, jwk}
    rescue
      _ -> {:error, :invalid_jwk}
    end
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
