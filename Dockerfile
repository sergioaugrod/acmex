FROM elixir:1.6

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /acmex