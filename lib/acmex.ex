defmodule Acmex do
  @moduledoc """
  This module provides the main API to interface with Acme.
  """

  alias Acmex.Client
  alias Acmex.Resource.{Account, Challenge, Order}
  alias HTTPoison.Response

  @type account_reply :: {:ok, Account.t()} | {:error, Response.t()}
  @type challenge_reply :: {:ok, Challenge.t()} | {:error, Response.t()}
  @type certificate_reply :: {:ok, String.t()} | {:error, Response.t()}
  @type certificate_revocation_reply :: :ok | {:error, Response.t()}
  @type on_start_link ::
          {:ok, pid()}
          | :ignore
          | {:error, {:already_started, pid()} | term()}
          | {:error, String.t()}
  @type order_reply :: {:ok, Order.t()} | {:error, Response.t()}

  @timeout 5_000

  @doc """
  Starts the client with a private key.

  If the private key path does not exists, the client will not start.

  ## Parameters

    - keyfile: The path to an RSA key.
    - name: Optional name for the Client.

  ## Examples

      iex> Acmex.start_link(keyfile: "test/support/fixture/account.key")
      {:ok, #PID<...>}

      iex> Acmex.start_link(key: "-----BEGIN RSA PRIVATE KEY-----...", name: :acmex_optional_name)
      {:ok, #PID<...>}

  """
  @spec start_link(keyword()) :: on_start_link()
  def start_link(opts) do
    name = Keyword.get(opts, :name, Client)
    keyfile = Keyword.get(opts, :keyfile)
    key = Keyword.get(opts, :key)

    cond do
      keyfile && File.exists?(keyfile) ->
        Client.start_link(File.read!(keyfile), name)

      is_binary(key) && key != "" ->
        Client.start_link(key, name)

      true ->
        {:error, "empty key or keyfile does not exist"}
    end
  end

  @doc """
  Creates a new account.

  ## Parameters

    - contact: A list of URLs that the ACME can use to contact the client for issues related to this account.
    - tos: Terms Of Service Agreed indicates the client's agreement with the terms of service.
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.new_account(["mailto:info@example.com"], true)
      {:ok, %Account{...}}

  """
  @spec new_account([String.t()], boolean(), pos_integer()) :: account_reply()
  def new_account(contact, tos, timeout \\ @timeout),
    do: GenServer.call(Client, {:new_account, contact, tos}, timeout)

  @doc """
  Gets an existing account.

  An account will only be returned if the current private key has been used to create a new account.

  ## Parameters

    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.get_account()
      {:ok, %Account{...}}

  """
  @spec get_account(pos_integer()) :: account_reply()
  def get_account(timeout \\ @timeout), do: GenServer.call(Client, :get_account, timeout)

  @doc """
  Creates a new order.

  ## Parameters

    - identifiers: A list of domains.
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.new_order(["example.com"])
      {:ok, %Order{...}}

  """
  @spec new_order([String.t()], pos_integer()) :: order_reply()
  def new_order(identifiers, timeout \\ @timeout),
    do: GenServer.call(Client, {:new_order, identifiers}, timeout)

  @doc """
  Gets an existing order.

  ## Parameters

    - url: The url attribute of the order resource.
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.get_order(order.url)
      {:ok, %Order{...}}

  """
  @spec get_order(String.t(), pos_integer()) :: order_reply()
  def get_order(url, timeout \\ @timeout), do: GenServer.call(Client, {:get_order, url}, timeout)

  @doc """
  Gets an existing challenge.

  ## Parameters

    - url: The url attribute of the challenge resource.
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.get_challenge(%Challenge{...}.url)
      {:ok, %Challenge{...}}

  """
  @spec get_challenge(String.t(), pos_integer()) :: challenge_reply()
  def get_challenge(url, timeout \\ @timeout),
    do: GenServer.call(Client, {:get_challenge, url}, timeout)

  @doc """
  Gets the challenge response.

  ## Parameters

    - challenge: The challenge resource.
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.get_challenge_response(%Challenge{token: "bZxymov025OYA4DkGSI5XPKdAW9V93eKoDZZ56AC3cI", type: "dns-01"})
      {:ok,
       %{
         key_authorization: "AgemQZ-WIft7VwWljRb3l_nkyigEILfRzzx5E6HdFyY",
         record_name: "_acme-challenge",
         record_type: "TXT"
       }}

      iex> Acmex.get_challenge_response(%Challenge{token: "oR3Xwj4GgXIxUtKMUfmVf4hmRFehAIgSsg7oXD_PCEw", type: "http-01"})
      {:ok,
       %{
         content_type: "text/plain",
         filename: ".well-known/acme-challenge/oR3Xwj4GgXIxUtKMUfmVf4hmRFehAIgSsg7oXD_PCEw",
         key_authorization: "oR3Xwj4GgXIxUtKMUfmVf4hmRFehAIgSsg7oXD_PCEw.5zmJUVWaucybUNJSLeCaO9D_cauS5QiwA92KTiY_vNc"
       }}

  """
  @spec get_challenge_response(Challenge.t(), pos_integer()) :: {:ok, map()}
  def get_challenge_response(challenge, timeout \\ @timeout),
    do: GenServer.call(Client, {:get_challenge_response, challenge}, timeout)

  @doc """
  Validates the challenge.

  ## Parameters

    - challenge: The challenge resource.
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.validate_challenge(%Challenge{...})
      {:ok, %Challenge{...}}

  """
  @spec validate_challenge(Challenge.t(), pos_integer()) :: challenge_reply()
  def validate_challenge(challenge, timeout \\ @timeout),
    do: GenServer.call(Client, {:validate_challenge, challenge}, timeout)

  @doc """
  Finalizes the order.

  ## Parameters

    - order: The order resource with status "pending".
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.finalize_order(%Order{status: "pending"})
      {:ok, %Order{status: "processing"}}

  """
  @spec finalize_order(Order.t(), String.t(), pos_integer()) :: challenge_reply()
  def finalize_order(order, csr, timeout \\ @timeout),
    do: GenServer.call(Client, {:finalize_order, order, csr}, timeout)

  @doc """
  Gets the certificate.

  The format of the certificate is application/pem-certificate-chain.

  ## Parameters

    - order: The order resource with status "valid".
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.get_certificate(%Order{status: "valid"})
      {:ok, "-----BEGIN CERTIFICATE-----..."}

  """
  @spec get_certificate(Order.t(), pos_integer()) :: certificate_reply()
  def get_certificate(order, timeout \\ @timeout),
    do: GenServer.call(Client, {:get_certificate, order}, timeout)

  @doc """
  Revokes a certificate.

  ## Parameters

    - certificate: The certificate to be revoked.
    - reason: Optional revocation reason code.
    - timeout: Process timeout in milliseconds. Default: 5_000.

  ## Examples

      iex> Acmex.revoke_certificate("-----BEGIN CERTIFICATE-----...", 0)
      :ok

  """
  @spec revoke_certificate(String.t(), pos_integer(), pos_integer()) ::
          certificate_revocation_reply()
  def revoke_certificate(certificate, reason_code \\ 0, timeout \\ @timeout) do
    GenServer.call(Client, {:revoke_certificate, certificate, reason_code}, timeout)
  end

  @spec child_spec(list()) :: Supervisor.child_spec()
  def child_spec(args) do
    %{
      id: __MODULE__,
      type: :worker,
      start: {__MODULE__, :start_link, args}
    }
  end
end
