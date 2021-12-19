defmodule TestEntity do
  @moduledoc false

  defstruct name: nil, age: 0
  import Altex.Persistable.Validators

  alias Altex.Persistable

  defimpl Persistable do
    def init(d), do: d

    def get(d, :name), do: d.name
    def get(d, :age), do: d.age

    def validate(_data, entity) do
      entity
      |> validate_presence([:name])
      |> validate_greater_or_equal_than(age: 18)
    end
  end
end
