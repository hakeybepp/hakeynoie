defmodule Hakeynoie.Bookings.BookingHistory do
  use Ash.Resource,
    domain: Hakeynoie.Bookings,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "booking_histories"
    repo Hakeynoie.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :booking_id, :uuid, allow_nil?: true, public?: true
    attribute :user_id, :uuid, allow_nil?: false, public?: true
    attribute :changed_by_id, :uuid, allow_nil?: false, public?: true
    attribute :action, :string, allow_nil?: false, public?: true
    attribute :snapshot, :map, allow_nil?: false, public?: true
    create_timestamp :inserted_at
  end

  actions do
    create :record do
      accept [:booking_id, :user_id, :changed_by_id, :action, :snapshot]
    end

    read :for_user do
      primary? true
      argument :user_id, :uuid, allow_nil?: false
      filter expr(user_id == ^arg(:user_id))
    end

    read :all do
    end
  end
end
