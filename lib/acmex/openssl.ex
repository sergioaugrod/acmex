defmodule Acmex.OpenSSL do
  @moduledoc false

  @default_rsa_size 2048
  @subject_keys %{
    common_name: "CN",
    country_name: "C",
    locality_name: "L",
    organization_name: "O",
    organizational_unit: "OU",
    state_or_province: "ST"
  }

  def generate_key(:rsa, key_path) do
    case openssl(~w(genrsa -out #{key_path} #{@default_rsa_size})) do
      {:ok, _} -> {:ok, key_path}
      {:error, error} -> {:error, error}
    end
  end

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
