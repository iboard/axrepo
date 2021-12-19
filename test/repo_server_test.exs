defmodule RepoServerTest do
  use ExUnit.Case, async: false

  alias Altex.{
    Repo.Server,
    Repo.Gateway,
    Entity
  }

  setup _ do
    Gateway.drop!(:my_repo)
    :ok
  end

  test "start the repo-server" do
    {:ok, pid} = Server.start_link(:my_repo)
    assert is_pid(pid)
  end

  test "store an entity and retreive it again" do
    {:ok, _pid} = Server.start_link(:my_repo)

    {:ok, e1} =
      Entity.init(%{id: 1, name: "Andi"})
      |> Server.store(:my_repo)

    {:ok, e2} =
      Entity.init(%{id: 2, name: "Heidi"})
      |> Server.store(:my_repo)

    assert 2 == Server.list(:my_repo) |> length()

    assert {:ok, ^e1} = Server.load(:my_repo, e1.uuid)
    assert {:ok, ^e2} = Server.load(:my_repo, e2.uuid)
  end
end
