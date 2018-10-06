defmodule Acmex do
  alias Acmex.Client

  def start_link(keyfile), do: GenServer.start_link(Client, [keyfile: keyfile], name: Client)

  def new_account(contact, tos), do: GenServer.call(Client, {:new_account, contact, tos})

  def get_account, do: GenServer.call(Client, :get_account)

  def new_order(identifiers), do: GenServer.call(Client, {:new_order, identifiers})

  def get_order(url), do: GenServer.call(Client, {:get_order, url})

  def get_challenge(url), do: GenServer.call(Client, {:get_challenge, url})

  def get_challenge_response(challenge),
    do: GenServer.call(Client, {:get_challenge_response, challenge})

  def validate_challenge(challenge), do: GenServer.call(Client, {:validate_challenge, challenge})

  def finalize_order(order, csr), do: GenServer.call(Client, {:finalize_order, order, csr})

  def get_certificate(order), do: GenServer.call(Client, {:get_certificate, order})
end
