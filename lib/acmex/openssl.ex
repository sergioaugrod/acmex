defmodule Acmex.OpenSSL do
  @moduledoc """
  This module provides functions to generate a Private Key and Certificate Signing Request.
  """

  @type rsa_key_sizes :: 2048 | 3082 | 4096

  @rsa_key_sizes [2048, 3072, 4096]
  @subject_keys %{
    common_name: "CN",
    country_name: "C",
    locality_name: "L",
    organization_name: "O",
    organizational_unit: "OU",
    state_or_province: "ST"
  }

  @doc """
  Generates a RSA private key.

  ## Parameters

    - type: Private key type.
    - key_path: Private key path.
    - size: Private key size.

  ## Examples

      iex> Acmex.OpenSSL.generate_key(:rsa, "/tmp/private.key")
      {:ok, "/tmp/private.key"}

  """
  @spec generate_key(:rsa, binary(), rsa_key_sizes()) :: {:ok, binary()} | {:error, binary()}
  def generate_key(:rsa, key_path, size \\ 2048) when size in @rsa_key_sizes do
    case openssl(~w(genrsa -out #{key_path} #{size})) do
      {:ok, _} -> {:ok, key_path}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Generates a Certificate Signing Request.

  ## Parameters

    - key_path: Private key path.
    - subject: Subject attributes.

  ## Examples

      iex> subject = %{common_name: "example.com"}
      iex> Acmex.OpenSSL.generate_csr("/tmp/private.key", subject)
      {:ok, <<48, 130, 2, 91, 48, 1, ...>>}

  """
  @spec generate_csr(binary(), Map.t()) :: {:ok, bitstring()} | {:error, binary()}
  def generate_csr(key_path, subject) do
    openssl(~w(req -new -nodes -key #{key_path} -subj #{format_subject(subject)} -outform DER))
  end

  defp openssl(args) do
    case System.cmd("openssl", args, stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {error, 1} -> {:error, error}
    end
  end

  defp format_subject(subject) do
    subject
    |> Enum.map(fn {k, v} -> "/#{@subject_keys[k]}=#{v}" end)
    |> Enum.join()
  end
end
