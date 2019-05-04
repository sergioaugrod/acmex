# Acmex [![Build Status](https://travis-ci.org/sergioaugrod/acmex.svg?branch=master)](https://travis-ci.org/sergioaugrod/acmex)

Acmex is an Elixir Client for the Lets Encrypt [ACMEv2](https://github.com/ietf-wg-acme/acme) protocol.

The client provides basic functions to create a certificate with `Lets Encrypt ACMEv2`, but there are features that haven't yet been implemented.

## Installation

The package can be installed by adding `acmex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:acmex, github: "sergioaugrod/acmex"}
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
Acmex.start_link(keyfile: "/path/account.key")
# or with a plaintext key loaded from ENV or other...
Acmex.start_link(key: "/path/account.key")
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
{:ok, order} = Acmex.new_order(["example.com"])
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
Acmex.OpenSSL.generate_key(:rsa, "/path/order.key")
{:ok, csr} = Acmex.OpenSSL.generate_csr("/path/order.key", %{common_name: "saugrod.tk"})
{:ok, order} = Acmex.finalize_order(order, csr)
```

#### Get the certificate

```elixir
Acmex.get_certificate(order)
```

## Development

To run the tests you need an `ACME Test Server`. You can use [Pebble](https://github.com/letsencrypt/pebble):

```bash
$ docker run -e "PEBBLE_VA_NOSLEEP=1" -e "PEBBLE_VA_ALWAYS_VALID=1" -e "PEBBLE_WFE_NONCEREJECT=0" -p 14000:14000 letsencrypt/pebble:2.0.2
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

## License

MIT License

Copyright (c) 2018 Sérgio Rodrigues

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
