defmodule Acmex.Resource.Authorization do
  @moduledoc """
  This structure represents an authorization for an account.
  """

  alias Acmex.Resource.Challenge

  @enforce_keys ~w(challenges identifier status)a

  defstruct ~w(challenges expires identifier status)a

  @type t :: %__MODULE__{
          challenges: [Challenge.t()],
          expires: String.t(),
          identifier: %{type: String.t(), value: String.t()},
          status: String.t()
        }

  @doc """
  Builds an authorization struct.
  """
  @spec new(map()) :: t()
  def new(%{challenges: challenges} = authorization) do
    challenges = Enum.map(challenges, &Challenge.new(&1))
    authorization = %{authorization | challenges: challenges}

    struct(__MODULE__, authorization)
  end

  @doc """
  Returns the HTTP challenge from an authorization.
  """
  @spec http(t()) :: Challenge.t()
  def http(%__MODULE__{challenges: challenges}), do: get_challenge(challenges, "http-01")

  @doc """
  Returns the DNS challenge from an authorization.
  """
  @spec dns(t()) :: Challenge.t()
  def dns(%__MODULE__{challenges: challenges}), do: get_challenge(challenges, "dns-01")

  defp get_challenge(challenges, type), do: Enum.find(challenges, &(&1.type == to_string(type)))
end
