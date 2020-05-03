defmodule Acmex.Resource.Account do
  @moduledoc """
  This structure represents an account.
  """

  @enforce_keys ~w(contact status url)a

  defstruct @enforce_keys

  @type t :: %__MODULE__{contact: [String.t()], status: String.t(), url: String.t()}

  @doc """
  Builds an account.
  """
  @spec new(map()) :: t()
  def new(account), do: struct(__MODULE__, account)
end
