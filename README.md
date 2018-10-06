# Acmex

Amcex is a Elixir Client for Lets Encrypt [ACMEv2](https://github.com/ietf-wg-acme/acme) protocol.

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

If you need a staging version of `Lets Encrypt ACMEv2` set `directory_url` as https://acme-staging-v02.api.letsencrypt.org/directory.

## Usage

## Development

### Running Tests locally

You need an ACME test server, we recommend [pebble](https://github.com/letsencrypt/pebble):

```bash
$ docker run -e "PEBBLE_VA_NOSLEEP=1" -e "PEBBLE_VA_ALWAYS_VALID=1" -e "PEBBLE_WFE_NONCEREJECT=0" -p 14000:14000 letsencrypt/pebble:2018-09-28
```

After execute the ACME test server, run the tests:

```bash
$ mix test
```

### Running Tests in Docker

```bash
docker-compose run test
```
