defmodule Acmex.Client do
  @moduledoc false

  use GenServer

  alias Acmex.{Crypto, Request}
  alias Acmex.Resource.{Account, Challenge, Directory, Order}

  def init(keyfile: keyfile) do
    with true <- File.exists?(keyfile),
         {:ok, directory} <- Directory.new() do
      state = %{
        directory: directory,
        jwk: Crypto.get_jwk(keyfile),
        account: nil
      }

      {:ok, state}
    else
      false -> {:stop, "keyfile #{keyfile} does not exists"}
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

    with {:ok, %{url: kid}} <- get_account(state.account, state.directory, state.jwk),
         {:ok, nonce} <- get_nonce(state.directory),
         {:ok, resp} <- Request.post(state.directory.new_order, state.jwk, payload, nonce, kid) do
      {:reply, {:ok, Order.new(resp.body, resp.headers)}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:get_order, url}, _from, state),
    do: {:reply, Order.reload(%Order{url: url}), state}

  def handle_call({:get_challenge, url}, _from, state),
    do: {:reply, Challenge.reload(%Challenge{url: url}), state}

  def handle_call({:get_challenge_response, challenge}, _from, %{jwk: jwk} = state),
    do: {:reply, Challenge.get_response(challenge, jwk), state}

  def handle_call({:validate_challenge, challenge}, _from, state) do
    {:ok, key_authorization} = Challenge.get_key_authorization(challenge, state.jwk)
    payload = %{key_authorization: key_authorization}

    with {:ok, %{url: kid}} <- get_account(state.account, state.directory, state.jwk),
         {:ok, nonce} <- get_nonce(state.directory),
         {:ok, resp} <- Request.post(challenge.url, state.jwk, payload, nonce, kid) do
      {:reply, {:ok, Challenge.new(resp.body)}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:finalize_order, order, csr}, _from, state) do
    payload = %{csr: Base.url_encode64(csr, padding: false)}

    with {:ok, %{url: kid}} <- get_account(state.account, state.directory, state.jwk),
         {:ok, nonce} <- get_nonce(state.directory),
         {:ok, resp} <- Request.post(order.finalize, state.jwk, payload, nonce, kid) do
      {:reply, {:ok, Order.new(resp.body, resp.headers)}, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:get_certificate, order}, _from, state) do
    case Request.get(order.certificate, [{"Accept", "application/pem-certificate-chain"}], nil) do
      {:ok, resp} -> {:reply, {:ok, resp.body}, state}
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
end
