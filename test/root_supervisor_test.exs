defmodule RepoSupervisorTest do
  use ExUnit.Case, async: false

  alias Altex.{Entity, Repo}

  describe "implementation:" do
    test "start the 'Repo.Supervisor' with the 'Application'" do
      root_supervisor = GenServer.whereis(:repo_supervisor)
      assert is_pid(root_supervisor)
    end
  end

  describe "integration:" do
    test "with two repos and two entities each, store and read again" do
      # Given two repos
      Repo.start_repo(:people, :drop!)
      Repo.start_repo(:accounts, :drop!)

      # When inserting new entities
      {:ok, bob} =
        Entity.init(%{name: "Bob", country: "US"})
        |> Repo.store(:people)

      {:ok, alice} =
        Entity.init(%{name: "Alice", country: "AT"})
        |> Repo.store(:people)

      {:ok, bank1} =
        Entity.init(%{name: "bank 1", balance: 0})
        |> Repo.store(:accounts)

      {:ok, bank2} =
        Entity.init(%{name: "bank 2", balance: 100})
        |> Repo.store(:accounts)

      # Then we can load them back by uuid
      {:ok, ^bob} = Repo.load(:people, bob.uuid)
      {:ok, ^alice} = Repo.load(:people, alice.uuid)
      {:ok, ^bank1} = Repo.load(:accounts, bank1.uuid)
      {:ok, ^bank2} = Repo.load(:accounts, bank2.uuid)
    end
  end

  describe "supervision" do
    setup _ do
      Repo.start_repo(:people, :drop!)

      {:ok, bob} =
        Entity.init(%{name: "Bob", balance: 0})
        |> Repo.store(:people)

      {:ok, %{bob: bob}}
    end

    test "restarting repos (`Server`) from supervisor without loss of data", %{bob: bob} do
      # Given a repository server
      server_pid_before = Process.whereis(:people)
      {:ok, ^bob} = Repo.load(:people, bob.uuid)

      # When killing it and wait 10ms to give the supervisor time to react
      Process.exit(server_pid_before, :kill)
      :timer.sleep(10)

      # Then the repo has restarted
      server_pid_restarted = GenServer.whereis(:people)
      assert is_pid(server_pid_restarted)
      assert server_pid_restarted != server_pid_before

      # And we still able to find bob
      {:ok, ^bob} = Repo.load(:people, bob.uuid)
    end
  end
end
