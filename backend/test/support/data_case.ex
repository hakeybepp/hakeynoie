defmodule Hakeynoie.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Hakeynoie.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Hakeynoie.DataCase
    end
  end

  setup tags do
    Hakeynoie.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Hakeynoie.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end
end
