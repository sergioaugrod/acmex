defmodule Acmex do
  alias Acmex.Client
  alias Acmex.Resource.{Account, Challenge, Order}

  @spec start_link(String.t()) :: {:ok, pid()} | {:error, Tuple.t()}
  def start_link(keyfile), do: GenServer.start_link(Client, [keyfile: keyfile], name: Client)

  @spec new_account(List.t(), Boolean.t()) :: {:ok, Account.t()} | {:error, any()}
  def new_account(contact, tos), do: GenServer.call(Client, {:new_account, contact, tos})

  @spec get_account() :: {:ok, Account.t()} | {:error, any()}
  def get_account, do: GenServer.call(Client, :get_account)

  @spec new_order(List.t()) :: {:ok, Order.t()} | {:error, any()}
  def new_order(identifiers), do: GenServer.call(Client, {:new_order, identifiers})

  @spec get_order(String.t()) :: {:ok, Order.t()} | {:error, any()}
  def get_order(url), do: GenServer.call(Client, {:get_order, url})

  @spec get_challenge(String.t()) :: {:ok, Challenge.t()} | {:error, any()}
  def get_challenge(url), do: GenServer.call(Client, {:get_challenge, url})

  @spec get_challenge_response(Challenge.t()) :: String.t()
  def get_challenge_response(challenge),
    do: GenServer.call(Client, {:get_challenge_response, challenge})

  @spec validate_challenge(Challenge.t()) :: {:ok, Challenge.t()} | {:error, any()}
  def validate_challenge(challenge), do: GenServer.call(Client, {:validate_challenge, challenge})

  @spec finalize_order(Order.t(), binary()) :: {:ok, Order.t()} | {:error, any()}
  def finalize_order(order, csr), do: GenServer.call(Client, {:finalize_order, order, csr})

  @spec get_certificate(Order.t()) :: {:ok, String.t()} | {:error, any()}
  def get_certificate(order), do: GenServer.call(Client, {:get_certificate, order})
end
