FROM elixir:1.9.1

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /acmex
