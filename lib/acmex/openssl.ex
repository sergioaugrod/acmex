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
    - size: Private key size.

  ## Examples

      iex> Acmex.OpenSSL.generate_key(:rsa, 2048)
      "-----BEGIN RSA PRIVATE KEY-----..."

  """
  @spec generate_key(:rsa, rsa_key_sizes()) :: String.t()
  def generate_key(:rsa, size \\ 2048) when size in @rsa_key_sizes do
    key = :public_key.generate_key({:rsa, size, 65_537})
    :public_key.pem_encode([:public_key.pem_entry_encode(:RSAPrivateKey, key)])
  end

  @doc """
  Generates a Certificate Signing Request.

  ## Parameters

    - key_path: Private key path.
    - domains: List of domains.
    - subject: Subject attributes.

  ## Examples

      iex> subject = %{organization_name: "Example"}
      iex> Acmex.OpenSSL.generate_csr("-----BEGIN RSA PRIVATE KEY-----...", ["example.com"], subject)
      {:ok, <<48, 130, 2, 91, 48, 1, ...>>}

  """
  @spec generate_csr(String.t(), list(), map()) :: {:ok, bitstring()} | {:error, String.t()}
  def generate_csr(key, domains, subject \\ %{}) do
    csr_config_tempfile = "/tmp/#{Enum.join(domains, "")}-#{:os.system_time()}.csr"
    key_tempfile = "/tmp/#{Enum.join(domains, "")}-#{:os.system_time()}.key"

    File.write!(csr_config_tempfile, csr_config(domains))
    File.write!(key_tempfile, key)

    result =
      openssl(
        ~w(req -new -sha256 -key #{key_tempfile} -subj #{format_subject(subject)} -reqexts SAN -config #{
          csr_config_tempfile
        } -outform DER)
      )

    File.rm!(csr_config_tempfile)
    File.rm!(key_tempfile)

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
