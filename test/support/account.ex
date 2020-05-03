defmodule Acmex.Support.Account do
  @moduledoc false

  alias Acmex.Crypto

  def jwk do
    "test/support/fixture/account.key"
    |> File.read!()
    |> Crypto.fetch_jwk_from_key()
    |> elem(1)
  end
end
