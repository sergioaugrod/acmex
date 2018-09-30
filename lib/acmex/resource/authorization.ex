defmodule Acmex.Resource.Authorization do
  alias Acmex.Resource.Challenge

  defstruct [
    :challenges,
    :expires,
    :identifier,
    :status
  ]

  def new(%{challenges: challenges} = authorization) do
    challenges = Enum.map(challenges, &struct(Challenge, &1))
    authorization = %{authorization | challenges: challenges}

    struct(__MODULE__, authorization)
  end

  def http(%__MODULE__{challenges: challenges}),
    do: get_challenge(challenges, "http-01")

  def dns(%__MODULE__{challenges: challenges}),
    do: get_challenge(challenges, "dns-01")

  defp get_challenge(challenges, type),
    do: Enum.find(challenges, &(&1.type == to_string(type)))
end
