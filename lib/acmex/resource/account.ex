defmodule Acmex.Resource.Account do
  defstruct [
    :agreement,
    :contact,
    :created_at,
    :id,
    :status,
    :url
  ]

  def new(account) do
    %__MODULE__{
      agreement: account[:agreement],
      contact: account[:contact],
      created_at: account[:createdAt],
      id: account[:id],
      status: account[:status],
      url: account[:url]
    }
  end
end
