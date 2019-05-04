defmodule Acmex.Client do
  @moduledoc false

  use GenServer

  alias Acmex.{Crypto, Request}
  alias Acmex.Resource.{Account, Authorization, Challenge, Directory, Order}

  def init(opts \\ []) do
    keyfile = Keyword.get(opts, :keyfile)
    key = Keyword.get(opts, :key)

    with {:ok, jwk} <-
           (cond do
              keyfile ->
                if File.exists?(keyfile) do
                  Crypto.fetch_jwk_from_file(keyfile)
                else
                  {:error, :keyfile_enoent}
                end

              key ->
                Crypto.fetch_jwk(key)

              true ->
                {:error, :no_key_opt}
            end),
         {:ok, directory} <- Directory.new() do
      state = %{
        directory: directory,
        jwk: jwk,
        account: nil
      }

      {:ok, state}
    else
      {:error, :no_key_opt} -> {:stop, "key or keyfile opt must be present"}
      {:error, :keyfile_enoent} -> {:stop, "supplied keyfile #{keyfile} does not exists"}
      {:error, :invalid_jwk} -> {:stop, "supplied key could not be parsed to JWK"}
      {:error, error} -> {:stop, error}
    end
  end

  def handle_call({:new_account, contact, terms_of_service_agreed}, _from, state) do
    payload = %{contact: contact, termsOfServiceAgreed: terms_of_service_agreed}

    case new_account(state.directory, state.jwk, payload) do
      {:ok, account} -> {:reply, {:ok, account}, %{state | account: account}}
      error -> {:reply, error, state}
    end
  end

  def handle_call(:get_account, _from, state) do
    case get_account(state.account, state.directory, state.jwk) do
      {:ok, account} -> {:reply, {:ok, account}, %{state | account: account}}
      error -> {:reply, error, state}
    end
  end

  def handle_call({:new_order, identifiers}, _from, state) do
    payload = %{identifiers: Enum.map(identifiers, &Map.new(type: "dns", value: &1))}

    with {:ok, resp} <- account_signed_post(state.directory.new_order, payload, state),
         order <- Order.new(resp.body, resp.headers),
         order <- fetch_authorizations(order, state) do
      {:reply, {:ok, order}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:get_order, url}, _from, state) do
    with {:ok, resp} <- account_post_as_get(url, state),
         order <- Order.new(resp.body, resp.headers),
         order <- fetch_authorizations(order, state),
         order <- %{order | url: url} do
      {:reply, {:ok, order}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:get_challenge, url}, _from, state) do
    with {:ok, resp} <- account_post_as_get(url, state),
         challenge <- Challenge.new(resp.body),
         challenge <- %{challenge | url: url} do
      {:reply, {:ok, challenge}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:get_challenge_response, challenge}, _from, %{jwk: jwk} = state),
    do: {:reply, Challenge.get_response(challenge, jwk), state}

  def handle_call({:validate_challenge, challenge}, _from, state) do
    {:ok, key_authorization} = Challenge.get_key_authorization(challenge, state.jwk)
    payload = %{key_authorization: key_authorization}

    with {:ok, resp} <- account_signed_post(challenge.url, payload, state) do
      {:reply, {:ok, Challenge.new(resp.body)}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:fetch_authorization, url}, _from, state) do
    with {:ok, resp} <- account_signed_post(url, nil, state) do
      {:reply, {:ok, resp.body}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:finalize_order, order, csr}, _from, state) do
    payload = %{csr: Base.url_encode64(csr, padding: false)}

    with {:ok, resp} <- account_signed_post(order.finalize, payload, state) do
      {:reply, {:ok, Order.new(resp.body, resp.headers)}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:get_certificate, order}, _from, state) do
    with {:ok, url} <-
           (case order.certificate do
              nil -> {:error, :certificate_not_ready}
              url -> {:ok, url}
            end),
         {:ok, resp} <-
           account_post_as_get(
             url,
             state,
             [{"Accept", "application/pem-certificate-chain"}],
             nil
           ) do
      {:reply, {:ok, resp.body}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:revoke_certificate, certificate, reason}, _from, state) do
    payload = %{
      certificate: Base.url_encode64(certificate, padding: false),
      reason: reason
    }

    with {:ok, resp} <-
           account_signed_post(
             state.directory.revoke_cert,
             payload,
             state,
             nil,
             nil
           ) do
      {:reply, :ok, state}
    else
      error -> {:reply, error, state}
    end
  end

  defp get_account(account, directory, jwk) when is_nil(account),
    do: new_account(directory, jwk, %{onlyReturnExisting: true})

  defp get_account(account, _directory, _jwk), do: {:ok, account}

  defp new_account(directory, jwk, payload) do
    with {:ok, nonce} <- get_nonce(directory),
         {:ok, resp} <- Request.post(directory.new_account, jwk, payload, nonce) do
      url = Request.get_header(resp.headers, "Location")
      {:ok, Account.new(Map.put(resp.body, :url, url))}
    else
      error -> error
    end
  end

  defp get_nonce(directory) do
    case Request.head(directory.new_nonce) do
      {:ok, resp} -> {:ok, Request.get_header(resp.headers, "Replay-Nonce")}
      error -> error
    end
  end

  defp fetch_authorizations(order, state) do
    %{order | authorizations: Enum.map(order.authorizations, &new_authorization(&1, state))}
  end

  defp new_authorization(url, state) do
    with {:ok, resp} <- account_post_as_get(url, state) do
      Authorization.new(resp.body)
    end
  end

  defp account_signed_post(url, payload, state, headers \\ [], handler \\ :decode) do
    with {:ok, %{url: kid}} <- get_account(state.account, state.directory, state.jwk),
         {:ok, nonce} <- get_nonce(state.directory),
         {:ok, resp} <- Request.post(url, state.jwk, payload, nonce, kid, headers, handler) do
      {:ok, resp}
    end
  end

  defp account_post_as_get(url, state, headers \\ [], handler \\ :decode) do
    account_signed_post(url, nil, state, headers, handler)
  end
end
