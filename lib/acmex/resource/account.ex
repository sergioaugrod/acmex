defmodule Acmex.Resource.Account do
  @moduledoc """
  This structure represents information about an account.
  """

  defstruct [
    :agreement,
    :contact,
    :created_at,
    :id,
    :status,
    :url
  ]

  def new(account), do: struct(__MODULE__, account)
end
