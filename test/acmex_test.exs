defmodule AcmexTest do
  use ExUnit.Case, async: true

  alias Acmex.{OpenSSL, Support}
  alias Acmex.Resource.{Account, Authorization}

  describe "start_link/1" do
    test "when keyfile exists, starts Acmex and returns `{:ok, pid()}`" do
      assert {:ok, _pid} =
               Acmex.start_link(keyfile: "test/support/fixture/account.key", name: :acmex_test)
    end

    test "when key is not empty, starts Acmex and returns `{:ok, pid()}`" do
      assert {:ok, _pid} = Acmex.start_link(key: OpenSSL.generate_key(:rsa), name: :acmex_test)
    end

    test "when keyfile does not exist, returns an error" do
      assert {:error, "empty key or keyfile does not exist"} =
               Acmex.start_link(keyfile: "test/support/fixture/account2.key", name: :acmex_test)
    end

    test "when key is empty, returns an error" do
      assert {:error, "empty key or keyfile does not exist"} =
               Acmex.start_link(key: "", name: :acmex_test)
    end

    test "when key is not an RSA key, returns an error" do
      assert {:error, "invalid key"} = Acmex.start_link(key: "123", name: :acmex_test)
    end
  end

  describe "new_account/2" do
    test "creates a new account" do
      {:ok, account} = Acmex.new_account(["mailto:info@example.com"], true)

      assert %Account{
               contact: ["mailto:info@example.com"],
               status: "valid"
             } = account
    end
  end

  describe "get_account/0" do
    test "returns the current account" do
      {:ok, account} = Acmex.get_account()

      assert %Account{
               contact: ["mailto:info@example.com"],
               status: "valid"
             } = account
    end
  end

  describe "new_order/1" do
    test "creates a new order" do
      {:ok, order} = Acmex.new_order(Support.Order.generate_random_domains(2))

      assert order.status == "pending"
      assert length(order.authorizations) == 2
    end
  end

  describe "get_order/1" do
    setup do
      {:ok, order} = Acmex.new_order(Support.Order.generate_random_domains())

      {:ok, order: order}
    end

    test "returns the order of the given url", %{order: order} do
      {:ok, order} = Acmex.get_order(order.url)

      assert order.status == "pending"
    end
  end

  describe "get_challenge/1" do
    setup do
      {:ok, order} = Acmex.new_order(Support.Order.generate_random_domains())
      authorization = List.first(order.authorizations)

      {:ok, challenge: Authorization.http(authorization)}
    end

    test "returns the challenge of the given url", %{challenge: challenge} do
      {:ok, challenge} = Acmex.get_challenge(challenge.url)

      assert challenge.status == "pending"
    end
  end

  describe "get_challenge_response/1" do
    setup do
      {:ok, order} = Acmex.new_order(Support.Order.generate_random_domains())
      authorization = List.first(order.authorizations)

      {:ok,
       dns_challenge: Authorization.dns(authorization),
       http_challenge: Authorization.http(authorization)}
    end

    test "when type is HTTP, returns the HTTP challenge response", %{http_challenge: challenge} do
      {:ok, response} = Acmex.get_challenge_response(challenge)

      assert String.length(response.key_authorization) == 87
      assert response.content_type == "text/plain"
      assert response.filename == ".well-known/acme-challenge/#{challenge.token}"
    end

    test "when type is DNS, returns the DNS challenge response", %{dns_challenge: challenge} do
      {:ok, response} = Acmex.get_challenge_response(challenge)

      assert String.length(response.key_authorization) == 43
      assert response.record_name == "_acme-challenge"
      assert response.record_type == "TXT"
    end
  end

  describe "validate_challenge/1" do
    setup do
      {:ok, order} = Acmex.new_order(Support.Order.generate_random_domains())
      authorization = List.first(order.authorizations)

      {:ok, challenge: Authorization.http(authorization)}
    end

    test "validates a challenge", %{challenge: challenge} do
      {:ok, challenge} = Acmex.validate_challenge(challenge)

      assert challenge.status == "pending"
      assert challenge.token
      assert challenge.type
      assert challenge.url
    end
  end

  describe "finalize_order/2" do
    setup do
      %{order: order, domains: domains} = Support.Order.create("valid")

      key = OpenSSL.generate_key(:rsa)
      {:ok, csr} = OpenSSL.generate_csr(key, domains)

      {:ok, csr: csr, order: order}
    end

    test "finalizes an order", %{csr: csr, order: order} do
      {:ok, order} = Acmex.finalize_order(order, csr)

      assert order.finalize
      assert order.status == "processing"
    end
  end

  describe "get_certificate/1" do
    setup do
      %{order: order} = Support.Order.create("finalized")

      {:ok, order: order}
    end

    test "returns the certificate", %{order: order} do
      {:ok, certificate} = Acmex.get_certificate(order)
      assert certificate =~ "BEGIN CERTIFICATE"
    end
  end

  describe "revoke_certificate/2" do
    setup do
      %{order: order} = Support.Order.create("finalized")
      {:ok, certificate} = Acmex.get_certificate(order)

      {:ok, certificate: certificate}
    end

    test "revokes a certificate", %{certificate: certificate} do
      assert Acmex.revoke_certificate(certificate, 0) == :ok
    end
  end
end
