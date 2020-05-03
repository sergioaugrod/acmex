defmodule Acmex.Resource.Directory do
  @moduledoc """
  This structure represents a directory.
  """

  alias Acmex.{Config, Request}

  @enforce_keys ~w(
    caa_identities
    key_change
    new_account
    new_order
    revoke_cert
    terms_of_service
    website
    new_nonce
  )a

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          caa_identities: String.t(),
          key_change: String.t(),
          new_account: String.t(),
          new_order: String.t(),
          revoke_cert: String.t(),
          terms_of_service: String.t(),
          website: String.t(),
          new_nonce: String.t()
        }

  @doc """
  Builds a directory struct.
  """
  @spec new(String.t()) :: {:ok, t()} | {:error, String.t()}
  def new(directory_url \\ Config.directory_url()) do
    directory_url
    |> get_directory()
    |> parse_directory()
  end

  defp get_directory(nil), do: {:error, "directory_url is not configured"}
  defp get_directory(directory_url), do: Request.get(directory_url)

  defp parse_directory({:error, reason}), do: {:error, reason}

  defp parse_directory({:ok, %{body: directory}}) do
    directory = %__MODULE__{
      caa_identities: get_in(directory, [:meta, :caaIdentities]),
      key_change: directory.keyChange,
      new_account: directory.newAccount,
      new_nonce: directory.newNonce,
      new_order: directory.newOrder,
      revoke_cert: directory.revokeCert,
      terms_of_service: get_in(directory, [:meta, :termsOfService]),
      website: get_in(directory, [:meta, :website])
    }

    {:ok, directory}
  end
end
