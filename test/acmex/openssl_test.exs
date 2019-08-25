defmodule Acmex.OpenSSLTest do
  use ExUnit.Case, async: true

  alias Acmex.OpenSSL

  describe "OpenSSL.generate_key/2" do
    test "generates a rsa private key" do
      key_path = "/tmp/#{:os.system_time()}"
      on_exit(fn -> File.rm!(key_path) end)

      assert OpenSSL.generate_key(:rsa, key_path) == {:ok, key_path}
      assert File.read!(key_path) =~ "PRIVATE KEY"
    end

    test "does not generate a rsa private key" do
      {:error, reason} = OpenSSL.generate_key(:rsa, "/path/invalid/tmp")

      assert reason =~ "No such file"
    end
  end

  describe "OpenSSL.generate_csr/3" do
    test "generates a certificate signing request file" do
      key_path = "/tmp/#{:os.system_time()}"
      OpenSSL.generate_key(:rsa, key_path)
      on_exit(fn -> File.rm!(key_path) end)

      {:ok, csr} =
        OpenSSL.generate_csr(key_path, ["example.com"], %{organization_name: "Example"})

      assert is_bitstring(csr)
    end
  end
end
