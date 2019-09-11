defmodule Acmex.Resource.Account do
  @moduledoc """
  This structure represents information about an account.
  """

  @enforce_keys [:contact, :status, :url]

  defstruct @enforce_keys

  @type t :: %__MODULE__{contact: [String.t()], status: String.t(), url: String.t()}

  @spec new(map()) :: __MODULE__.t()
  def new(account), do: struct(__MODULE__, account)
end
