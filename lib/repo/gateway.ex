defmodule Altex.Repo.Gateway do
  @doc ~s"""
  The _Gateway_ offers an API to `load_table(name)` and
  `store_table(name, key, value)`.

  **List of loaded tables**

  The 'state' of the server is the list of loaded table-names (as atoms).
  Accessing a table will ensure the table is loaded but will not reload it if
  it is in the list of loaded tables already.

  The server is started and registered by the name `:repo_gateway`. You may
  use another gateway in your application. Therefore, just implement a
  module which also registers as `:repo_gateway` and remove this basic
  ETS implementation from the `Application` child list.

  See the line `@implementation .....`. That's the place where you inject
  the implementation of your choice.
  """
  use GenServer

  alias Altex.Repo.Gateway

  # Inject the Gateway implementation
  @implementation Application.get_env(:axrepo, :gw_impl, Gateway.ETS )

  @doc ~s"""
  Start a singelton GenServer, registered as `:repo_gateway` with an empty
  list of loaded tables.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: :repo_gateway)
  end

  @impl true
  def init(tables) do
    {:ok, tables}
  end

  #### API ####################################################################

  @doc ~s"""
  Load the named table `store` and return a map of the format
  `%{ uuid => entity, uuid => entity, ... }` of the loaded entities.
  """
  def load_table(store) do
    GenServer.call(:repo_gateway, {:load_table, store})
  end

  @doc ~s"""
  Store the given `entity` at the given `uuid` in table `store`.
  """
  def store_table(store, uuid, entity) do
    GenServer.cast(:repo_gateway, {:store, store, uuid, entity})
  end

  @doc ~s"""
  Drop the given `store`. Mostly used for testing.
  """
  def drop!(store) do
    @implementation.drop!(store)
  end

  #### CALLBACKS ##############################################################

  @impl true
  def handle_call({:load_table, store}, _, tables) do
    tables = ensure_tables(store, tables)
    loaded = @implementation.load_table(store)

    {:reply, loaded, tables}
  end

  @impl true
  def handle_cast({:store, store, uuid, entity}, tables) do
    tables = ensure_tables(store, tables)

    @implementation.insert(store, {uuid, entity})

    {:noreply, tables}
  end

  ############################################################################

  defp ensure_tables(store, tables) do
    if store in tables,
      do: tables,
      else: [@implementation.open_table(store) | tables]
  end
end
