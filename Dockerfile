FROM elixir:1.7

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /acmex
