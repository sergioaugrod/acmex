defmodule Acmex.Resource.Authorization do
  @moduledoc """
  This structure represents an account authorization to act for an identifier.
  """

  alias Acmex.Resource.Challenge

  @enforce_keys [:challenges, :expires, :identifier, :status]

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          challenges: [Challenge.t()],
          expires: String.t(),
          identifier: %{type: String.t(), value: String.t()},
          status: String.t()
        }

  @spec new(map()) :: __MODULE__.t()
  def new(%{challenges: challenges} = authorization) do
    challenges = Enum.map(challenges, &Challenge.new(&1))
    authorization = %{authorization | challenges: challenges}

    struct(__MODULE__, authorization)
  end

  @spec http(__MODULE__.t()) :: Challenge.t()
  def http(%__MODULE__{challenges: challenges}),
    do: get_challenge(challenges, "http-01")

  @spec dns(__MODULE__.t()) :: Challenge.t()
  def dns(%__MODULE__{challenges: challenges}),
    do: get_challenge(challenges, "dns-01")

  defp get_challenge(challenges, type),
    do: Enum.find(challenges, &(&1.type == to_string(type)))
end
