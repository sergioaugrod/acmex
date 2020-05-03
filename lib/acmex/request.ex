defmodule Acmex.Request do
  @moduledoc """
  This module is responsible for requesting the ACME API.
  """

  alias Acmex.Crypto

  @type response :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  @user_agent "Acmex v#{Mix.Project.config()[:version]}"
  @default_headers [{"User-Agent", @user_agent}, {"Content-Type", "application/jose+json"}]

  @doc """
  Makes a GET request to fetch an unauthenticated resource.
  """
  @spec get(String.t(), keyword(), atom()) :: response()
  def get(url, headers \\ [], handler \\ :decode) do
    resp = HTTPoison.get(url, @default_headers ++ headers, hackney: hackney_opts())
    if handler, do: handle_response(resp, handler), else: handle_response(resp)
  end

  @doc """
  Makes a POST request.
  """
  @spec post(String.t(), tuple(), map(), String.t(), String.t() | nil) :: response()
  def post(url, jwk, payload, nonce, kid \\ nil) do
    jws = Crypto.sign(jwk, Jason.encode!(payload), jws_headers(url, nonce, kid))

    url
    |> HTTPoison.post(Jason.encode!(jws), @default_headers, hackney: hackney_opts())
    |> handle_response(:decode)
  end

  @doc """
  Makes a POST request to fetch an authenticated resource.
  """
  @spec post_as_get(String.t(), tuple(), String.t(), keyword()) :: response()
  def post_as_get(url, jwk, nonce, kid, headers \\ []) do
    jws = Crypto.sign(jwk, "", jws_headers(url, nonce, kid))

    url
    |> HTTPoison.post(Jason.encode!(jws), @default_headers ++ headers, hackney: hackney_opts())
    |> handle_response(if headers == [], do: :decode, else: nil)
  end

  @doc """
  Makes a HEAD request to an URL.
  """
  @spec head(String.t()) :: response()
  def head(url) do
    url
    |> HTTPoison.head([], hackney: hackney_opts())
    |> handle_response()
  end

  @doc """
  Gets a header by a given key.
  """
  @spec get_header(keyword(), String.t()) :: String.t() | nil
  def get_header(headers, key) do
    case List.keyfind(headers, key, 0) do
      nil -> nil
      {_, value} -> value
    end
  end

  defp handle_response(result, :decode) do
    case result do
      {:ok, %{status_code: 200} = resp} -> {:ok, decode_response(resp)}
      {:ok, %{status_code: 201} = resp} -> {:ok, decode_response(resp)}
      {:ok, resp} -> {:error, decode_response(resp)}
      {:error, error} -> {:error, decode_response(error)}
    end
  end

  defp handle_response(result, nil), do: handle_response(result)

  defp handle_response(result) do
    case result do
      {:ok, %{status_code: 200} = resp} -> {:ok, resp}
      {:ok, %{status_code: 204} = resp} -> {:ok, resp}
      {:ok, resp} -> {:error, decode_response(resp)}
      {:error, error} -> {:error, decode_response(error)}
    end
  end

  defp decode_response(%{body: ""} = resp), do: %{resp | body: %{}}
  defp decode_response(%{body: body} = resp), do: %{resp | body: decode_body(body)}
  defp decode_response(resp), do: resp

  defp decode_body(body) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, decoded_body} -> decoded_body
      {:error, _} -> body
    end
  end

  defp jws_headers(url, nonce, nil), do: %{"url" => url, "nonce" => nonce}
  defp jws_headers(url, nonce, kid), do: %{"url" => url, "nonce" => nonce, "kid" => kid}

  defp hackney_opts, do: Application.get_env(:acmex, :hackney_opts, [])
end
