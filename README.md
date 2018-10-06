# Acmex

Acmex is a Elixir Client for Lets Encrypt [ACMEv2](https://github.com/ietf-wg-acme/acme) protocol.

The client provides basic functions to create a certificate with `Lets Encrypt ACMEv2`, but there are features that haven't yet been implemented.

## Installation

The package can be installed by adding `acmex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:acmex, "~> 0.1.0"}
  ]
end
```

## Configure

Set the `directory_url` in your `config.exs`:

```elixir
config :acmex,
  directory_url: "https://acme-v02.api.letsencrypt.org/directory"
```

If you need a staging version of `Lets Encrypt ACMEv2` set the `directory_url` as https://acme-staging-v02.api.letsencrypt.org/directory.

## Usage

### Client

#### Starting the client

You need to generate a private key to start the client. Acmex actually expects a RSA Key.
If you don't have it, you can create one through Acmex:

```elixir
Acmex.OpenSSL.generate_key(:rsa, "/path/account.key")
```

And now start the client with the generated key file:

```elixir
Acmex.start_link("/path/account.key")
```

### Account

#### Creating a new account

```elixir
Acmex.new_account(["mailto:info@example.com"], true)
```

#### Fetch existing account

```elixir
Acmex.get_account()
```

### Order

#### Creating a new order

```elixir
Acmex.new_order(["example.com"])
```

#### Fetch an existing order

```elixir
Acmex.get_order(order.url)
```

### Challenge

#### Receive a challenge

```elixir
{:ok, order} = Acmex.new_order(["example.com"])
authorization = List.first(order.authorizations)
challenge = Authorization.http(authorization)
```

#### Return a challenge response

```elixir
Acmex.get_challenge_response(challenge)
```

#### Validate the challenge

```elixir
{:ok, challenge} = Acmex.validate_challenge(challenge)
```

### Certificate

#### Finalize an order

```elixir
{:ok, order} = Acmex.finalize_order(order, csr)
```

#### Get the certificate

```elixir
Acmex.get_certificate(order)
```

## Development

To run the tests you need an `ACME Test Server`. You can use [Pebble](https://github.com/letsencrypt/pebble):

```bash
$ docker run -e "PEBBLE_VA_NOSLEEP=1" -e "PEBBLE_VA_ALWAYS_VALID=1" -e "PEBBLE_WFE_NONCEREJECT=0" -p 14000:14000 letsencrypt/pebble:2018-09-28
$ mix test
```

Or using docker:

```bash
docker-compose run test
```

## Contributing

1. Clone it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
