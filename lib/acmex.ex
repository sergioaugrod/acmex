defmodule Acmex do
  @moduledoc """
  This module provides the main API to interface with Acme.
  """

  alias Acmex.Client
  alias Acmex.Resource.{Account, Challenge, Order}
  alias HTTPoison.Response

  @type account_reply :: {:ok, Account.t()} | {:error, Response.t()}
  @type challenge_reply :: {:ok, Challenge.t()} | {:error, Response.t()}
  @type certificate_reply :: {:ok, binary()} | {:error, Response.t()}
  @type on_start_link :: {:ok, pid()} | :ignore | {:error, {:already_started, pid()} | term()}
  @type order_reply :: {:ok, Order.t()} | {:error, Response.t()}

  @doc """
  Starts the client with a private key.

  If the private key path does not exists, the client will not start.

  ## Parameters

    - keyfile: The path to an RSA key.
    - name: Optional name for the Client.

  ## Examples

      iex> Acmex.start_link("test/support/fixture/account.key")
      {:ok, #PID<...>}

      iex> Acmex.start_link("test/support/fixture/account.key", :acmex_optional_name)
      {:ok, #PID<...>}

  """
  @spec start_link(binary(), atom()) :: on_start_link()
  def start_link(keyfile, name \\ Client),
    do: GenServer.start_link(Client, [keyfile: keyfile], name: name)

  @doc """
  Creates a new account.

  ## Parameters

    - contact: A list of URLs that the ACME can use to contact the client for issues related to this account.
    - tos: Terms Of Service Agreed indicates the client's agreement with the terms of service.

  ## Examples

      iex> Acmex.new_account(["mailto:info@example.com"], true)
      {:ok, %Account{...}}

  """
  @spec new_account([binary()], boolean()) :: account_reply()
  def new_account(contact, tos), do: GenServer.call(Client, {:new_account, contact, tos})

  @doc """
  Gets an existing account.

  An account will only be returned if the current private key has been used to create a new account.

  ## Examples

      iex> Acmex.get_account()
      {:ok, %Account{...}}

  """
  @spec get_account() :: account_reply()
  def get_account, do: GenServer.call(Client, :get_account)

  @doc """
  Creates a new order.

  ## Parameters
    - identifiers: A list of domains.

  ## Examples

      iex> Acmex.new_order(["example.com"])
      {:ok, %Order{...}}

  """
  @spec new_order([binary()]) :: order_reply()
  def new_order(identifiers), do: GenServer.call(Client, {:new_order, identifiers})

  @doc """
  Gets an existing order.

  ## Parameters

    - url: The url attribute of the order resource.

  ## Examples

      iex> Acmex.get_order(%{Order}.url)
      {:ok, %Order{...}}

  """
  @spec get_order(binary()) :: order_reply()
  def get_order(url), do: GenServer.call(Client, {:get_order, url})

  @doc """
  Gets an existing challenge.

  ## Parameters

  - url: The url attribute of the challenge resource.

  ## Examples

      iex> Acmex.get_challenge(%Challenge{...}.url)
      {:ok, %Challenge{...}}

  """
  @spec get_challenge(binary()) :: challenge_reply()
  def get_challenge(url), do: GenServer.call(Client, {:get_challenge, url})

  @doc """
  Gets the challenge response.

  ## Parameters

    - challenge: The challenge resource.

  ## Examples

      iex> Acmex.get_challenge_response(%Challenge{token: "LXk0qPoRi53T3nYAzB66IWpeWtaFQ4fGCp4IOiJY-Ms"})
      {:ok, "LXk0qPoRi53T3nYAzB66IWpeWtaFQ4fGCp4IOiJY-Ms.5zmJUVWaucybUNJSLeCaO9D_cauS5QiwA92KTiY_vNc"}

  """
  @spec get_challenge_response(Challenge.t()) :: {:ok, binary()}
  def get_challenge_response(challenge),
    do: GenServer.call(Client, {:get_challenge_response, challenge})

  @doc """
  Validates the challenge.

  ## Parameters

    - challenge: The challenge resource.

  ## Examples

      iex> Acmex.validate_challenge(%Challenge{...})
      {:ok, %Challenge{...}}

  """
  @spec validate_challenge(Challenge.t()) :: challenge_reply()
  def validate_challenge(challenge), do: GenServer.call(Client, {:validate_challenge, challenge})

  @doc """
  Finalizes the order.

  ## Parameters

    - order: The order resource with status "pending".

  ## Examples

      iex> Acmex.finalize_order(%Order{status: "pending"})
      {:ok, %Order{status: "processing"}}

  """
  @spec finalize_order(Order.t(), binary()) :: challenge_reply()
  def finalize_order(order, csr), do: GenServer.call(Client, {:finalize_order, order, csr})

  @doc """
  Gets the certificate.

  The format of the certificate is application/pem-certificate-chain.

  ## Parameters

    - order: The order resource with status "valid".

  ## Examples

      iex> Acmex.get_certificate(%Order{status: "valid"})
      {:ok, "-----BEGIN CERTIFICATE-----..."}

  """
  @spec get_certificate(Order.t()) :: certificate_reply()
  def get_certificate(order), do: GenServer.call(Client, {:get_certificate, order})
end
