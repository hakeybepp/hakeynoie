defmodule Hakeynoie.Repo.Migrations.AddBookingHistories do
  use Ecto.Migration

  def up do
    create table(:booking_histories, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :booking_id, :uuid
      add :user_id, :uuid, null: false
      add :changed_by_id, :uuid, null: false
      add :action, :string, null: false
      add :snapshot, :map, null: false
      timestamps(updated_at: false)
    end
  end

  def down do
    drop table(:booking_histories)
  end
end
