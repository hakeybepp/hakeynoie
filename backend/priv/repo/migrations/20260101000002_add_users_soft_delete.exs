defmodule Hakeynoie.Repo.Migrations.AddUsersSoftDelete do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :deleted_at, :utc_datetime_usec
    end
  end

  def down do
    alter table(:users) do
      remove :deleted_at
    end
  end
end
