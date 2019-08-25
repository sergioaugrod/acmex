defmodule Acmex.OpenSSL do
  @moduledoc """
  This module provides functions to generate a Private Key and Certificate Signing Request.
  """

  @type rsa_key_sizes :: 2048 | 3082 | 4096

  @rsa_key_sizes [2048, 3072, 4096]
  @subject_keys %{
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
    - domains: List of domains.
    - subject: Subject attributes.

  ## Examples

      iex> subject = %{organization_name: "Example"}
      iex> Acmex.OpenSSL.generate_csr("/tmp/private.key", ["example.com"], subject)
      {:ok, <<48, 130, 2, 91, 48, 1, ...>>}

  """
  @spec generate_csr(binary(), List.t(), Map.t()) :: {:ok, bitstring()} | {:error, binary()}
  def generate_csr(key_path, domains, subject \\ %{}) do
    csr_config_temp = "/tmp/#{Enum.join(domains, "")}-#{:os.system_time()}"
    File.write!(csr_config_temp, csr_config(domains))

    result =
      openssl(
        ~w(req -new -sha256 -key #{key_path} -subj #{format_subject(subject)} -reqexts SAN -config #{
          csr_config_temp
        } -outform DER)
      )

    File.rm!(csr_config_temp)
    result
  end

  defp csr_config(domains) do
    """
    [ req_distinguished_name ]

    [ req ]

    distinguished_name = req_distinguished_name

    [ v3_req ]

    keyUsage = nonRepudiation, digitalSignature, keyEncipherment

    [ SAN ]

    subjectAltName = DNS:#{Enum.join(domains, ", DNS:")}
    """
  end

  defp openssl(args) do
    case System.cmd("openssl", args, stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {error, 1} -> {:error, error}
    end
  end

  defp format_subject(%{}), do: "/"

  defp format_subject(subject) do
    subject
    |> Enum.map(fn {k, v} -> "/#{@subject_keys[k]}=#{v}" end)
    |> Enum.join()
  end
end
