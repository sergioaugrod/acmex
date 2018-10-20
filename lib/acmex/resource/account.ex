defmodule Acmex.Resource.Account do
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
