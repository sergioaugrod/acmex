defmodule Acmex.Crypto do
  @moduledoc """
  This module is responsible for providing functions to deal with JWK and JWS.
  """

  alias JOSE.{JWK, JWS}

  @alg "RS256"

  @doc """
  Builds a JWK `map` from an account key.
  """
  @spec fetch_jwk_from_key(String.t()) :: {:ok, tuple()} | {:error, String.t()}
  def fetch_jwk_from_key(key) do
    jwk =
      key
      |> JWK.from_pem()
      |> JWK.to_map()

    case jwk do
      [] -> {:error, "invalid key"}
      jwk -> {:ok, jwk}
    end
  end

  @doc """
  Signs a payload.
  """
  @spec sign(tuple(), String.t(), map()) :: map()
  def sign(jwk, payload, %{"kid" => _kid} = header) do
    jwk
    |> JWS.sign(payload, Map.put(header, "alg", @alg))
    |> elem(1)
  end

  def sign(jwk, payload, header) do
    {_, public_jwk} = JWK.to_public_map(jwk)

    jwk
    |> JWS.sign(payload, Map.merge(header, %{"alg" => @alg, "jwk" => public_jwk}))
    |> elem(1)
  end
end
