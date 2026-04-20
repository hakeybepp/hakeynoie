defmodule Hakeynoie.Repo.Migrations.CreateInitialSchema do
  use Ecto.Migration

  def up do
    # Extensions
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\""
    execute "CREATE EXTENSION IF NOT EXISTS citext"
    execute "CREATE EXTENSION IF NOT EXISTS btree_gist"

    # Users
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :email, :citext, null: false
      add :full_name, :string, null: false
      add :is_admin, :boolean, null: false, default: false
      add :hashed_password, :string

      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:users, [:email])

    # AshAuthentication token storage
    create table(:tokens, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :jti, :string, null: false
      add :subject, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :purpose, :string, null: false
      add :extra_data, :map

      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:tokens, [:jti])

    # Bookings
    create table(:bookings, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :check_in, :date, null: false
      add :check_out, :date, null: false
      add :notes, :text

      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create index(:bookings, [:user_id])

    execute """
    ALTER TABLE bookings
    ADD CONSTRAINT bookings_no_overlap
    EXCLUDE USING gist (daterange(check_in, check_out, '[)') WITH &&)
    """
  end

  def down do
    drop table(:bookings)
    drop table(:tokens)
    drop table(:users)
    execute "DROP EXTENSION IF EXISTS btree_gist"
    execute "DROP EXTENSION IF EXISTS citext"
    execute "DROP EXTENSION IF EXISTS \"uuid-ossp\""
  end
end
