ExUnit.start()

Acmex.start_link(keyfile: "test/support/fixture/account.key")
Acmex.new_account(["mailto:info@example.com"], true)
