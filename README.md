# README – Altex.Repo

[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](http://hexdocs.pm/axrepo/)
[![Elixir CI](https://github.com/iboard/axrepo/actions/workflows/elixir.yml/badge.svg)](https://github.com/iboard/axrepo/actions/workflows/elixir.yml)

A Repository for the "Altex Mix Projects".

## Installation

If [available in Hex](https://hex.pm/packages/axrepo), the package can be installed
by adding `axrepo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:axrepo, "~> 0.1"}
  ]
end
```

## Usage

```elixir
alias Altex.{Entity, Repo}

Repo.start_repo(:people)

{:ok, bob} = %{ name: "Bob", age: 57 } 
             |> Entity.init()
             |> Repo.store(:people)

{:ok ^bob} = Repo.load(:people, bob.id)

%{ bob | age: bob.age + 1 } |> Repo.store(:people)
```

