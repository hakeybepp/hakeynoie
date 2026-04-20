defmodule Hakeynoie.Repo.Migrations.AddTokensUpdatedAt do
  use Ecto.Migration

  def up do
    alter table(:tokens) do
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end
  end

  def down do
    alter table(:tokens) do
      remove :updated_at
    end
  end
end
