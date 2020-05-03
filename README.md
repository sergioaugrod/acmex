# Acmex

![](https://github.com/sergioaugrod/acmex/workflows/CI/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/v/acmex.svg)](https://hex.pm/packages/acmex)

Acmex is an Elixir Client for the Lets Encrypt [ACMEv2](https://github.com/ietf-wg-acme/acme) protocol.

## Installation

The package can be installed by adding `acmex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:acmex, "~> 0.1.2"}
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
key = Acmex.OpenSSL.generate_key(:rsa)
```

And now start the client with the generated key:

```elixir
Acmex.start_link(key: key)
```

To use on your supervisor:

```elixir
children = [
  {Acmex, [[key: "-----BEGIN RSA PRIVATE KEY-----..."]]}
]
```

### Account

#### Creating a new account

The second parameter is about the agreement of the terms of service.

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
authorization = List.first(order.authorizations)
challenge = Acmex.Resource.Authorization.http(authorization)
```

#### Return a challenge response

```elixir
Acmex.get_challenge_response(challenge)
```

#### Validate the challenge

```elixir
{:ok, challenge} = Acmex.validate_challenge(challenge)
```

#### Fetch an existing challenge

```elixir
Acmex.get_challenge(challenge.url)
```

### Certificate

#### Finalize an order

```elixir
order_key = Acmex.OpenSSL.generate_key(:rsa)
{:ok, csr} = Acmex.OpenSSL.generate_csr(order_key, ["example.com"])
{:ok, order} = Acmex.finalize_order(order, csr)
```

#### Get the certificate

```elixir
Acmex.get_certificate(order)
```

#### Revoke a certificate

```elixir
{:ok, certificate} = Acmex.get_certificate(order)
Acmex.revoke_certificate(certificate, 0)
```

## Documentation

The full documentation can be found at https://hexdocs.pm/acmex.

## Contributing

To run the tests you need an `ACME Test Server`. You can use [Pebble](https://github.com/letsencrypt/pebble).
For this reason, there is a `docker-compose.yml` file with `pebble` defined as a service.

To use `pebble` and run the tests:

```bash
$ docker-compose up
$ mix test
```

## License

MIT License

Copyright (c) 2020 Sérgio Rodrigues

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
