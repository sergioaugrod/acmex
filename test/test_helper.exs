ExUnit.start()

Acmex.start_link("test/support/fixture/account.key")
Acmex.new_account(["mailto:info@example.com"], true)
