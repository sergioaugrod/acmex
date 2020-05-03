defmodule Acmex.OpenSSLTest do
  use ExUnit.Case, async: true

  alias Acmex.OpenSSL

  describe "generate_key/2" do
    test "generates a RSA private key" do
      assert OpenSSL.generate_key(:rsa, 2048) =~ "PRIVATE KEY"
    end
  end

  describe "generate_csr/3" do
    test "generates a certificate signing request file" do
      key = OpenSSL.generate_key(:rsa)

      {:ok, csr} = OpenSSL.generate_csr(key, ["example.com"], %{organization_name: "Example"})

      assert is_bitstring(csr)
    end
  end
end
