defmodule Altex.Repo.Server do
  @moduledoc ~s"""
  Each "table" has it's own `Altex.Repo.Server` started from
  `Altex.Repo.start_repo/1` through the `Altex.Repo.Supervisor`.
  The repo will persist or not, based on the used gateway implementation.

  The supervisor takes care to restart the server in case of failure and
  the server re-loads data from the gateway on init.
  """

  alias Altex.{
    Entity,
    Repo.Gateway
  }

  use GenServer

  @doc ~s"""
  Start a repository server for the "table" `store`.

      ### Example:

      iex> {:ok, pid} = __MODULE__.start_link(:people)

  """
  def start_link(store) when is_atom(store) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, store, name: store)
  end

  @impl true
  def init(store) do
    {:ok, Gateway.load_table(store)}
  end

  # API #############################################################

  @doc ~s"""
  Store the given `entity` to the given `store`. If an entity with the
  same `uuid` exists, it will be updated, otherwise a new entity will
  be created.

  It returns `{:ok, valid_entity}` or `{:error, invalid_entity}`.
  """
  def store(entity, store) do
    GenServer.call(store, {:store, entity})
    |> handle_store()
  end

  @doc ~s"""
  Load the `Entity` with the given `uuid` from the given `store`.
  Returns `{:error, :not_found}` if the given `uuid` doesn't exist
  or `{:ok, entity}` when found.
  """
  def load(store, uuid) do
    with %Entity{} = e <- GenServer.call(store, {:load, uuid}) do
      {:ok, e}
    else
      e -> {:error, e}
    end
  end

  @doc ~s"""
  Return a list of all `Altex.Entity`s of the given `store`.
  """
  def list(store) when is_atom(store) do
    GenServer.call(store, :list)
  end

  @doc """
  Find an entity where the given field is equal to the
  example.
  """
  def find_by(example, field) do
    %type{} = example.data

    list(type)
    |> Enum.find(fn e -> Entity.get(e, field) == Entity.get(example, field) end)
  end

  def find_by(type, example, field) do
    list(type)
    |> Enum.find(fn e -> Entity.get(e, field) == Entity.get(example, field) end)
  end

  def drop!(type) do
    GenServer.call(type, :drop!)
  end


  ### Callbacks ####################################################

  @impl true
  def handle_info({:persist, entity}, store) do
    with table when is_atom(table) <- process_name(self()) do
      Gateway.store_table(table, entity.uuid, entity)
    else
      err -> raise("Can't store #{inspect(entity)} to #{store}. Error: #{inspect(err)}")
    end

    {:noreply, store}
  end

  @impl true
  def handle_call({:store, entity}, _, store) do
    map_key = get_key(entity)
    send(self(), {:persist, entity})
    {:reply, entity, Map.put(store, map_key, entity)}
  end

  @impl true
  def handle_call({:load, uuid}, _, store) do
    map_key = get_key(uuid)
    {:reply, Map.get(store, map_key, :not_found), store}
  end

  @impl true
  def handle_call(:list, _, store) do
    {:reply, Map.values(store), store}
  end

  @impl true
  def handle_call(:drop!, _, store) do
    {:reply, %{}, store}
  end

  # Implementation/Helpers ###################################################

  defp process_name(pid) do
    Process.info(pid)
    |> Keyword.get(:registered_name)
  end

  # ==========================================================================

  defp handle_store(entity)

  defp handle_store(%Entity{errors: []} = valid_entity) do
    {:ok, valid_entity}
  end

  defp handle_store(%Entity{errors: _errors} = invalid_entity) do
    {:error, invalid_entity}
  end

  # ==========================================================================

  defp get_key(uuid)
  defp get_key(uuid) when is_binary(uuid), do: uuid
  defp get_key(%{uuid: uuid}), do: uuid
end
