defmodule Hakeynoie.Bookings.Booking do
  use Ash.Resource,
    domain: Hakeynoie.Bookings,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "bookings"
    repo Hakeynoie.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :check_in, :date do
      allow_nil? false
      public? true
    end

    attribute :check_out, :date do
      allow_nil? false
      public? true
    end

    attribute :notes, :string do
      public? true
    end

    create_timestamp :created_at
  end

  relationships do
    belongs_to :user, Hakeynoie.Accounts.User do
      allow_nil? false
      public? true
    end
  end

  calculations do
    calculate :guest_name, :string, expr(user.full_name)
  end

  validations do
    validate compare(:check_out, greater_than: :check_in),
      message: "must be after check_in",
      where: [present(:check_in), present(:check_out)]
  end

  actions do
    read :read do
      primary? true
      prepare build(load: [:user, :guest_name])
    end

    read :for_month do
      argument :month, :string, allow_nil?: false
      prepare Hakeynoie.Bookings.ForMonthPreparation
    end

    read :for_month_admin do
      argument :month, :string, allow_nil?: false
      prepare Hakeynoie.Bookings.ForMonthPreparation
      prepare build(load: [:user, :guest_name])
    end

    create :create do
      primary? true
      accept [:check_in, :check_out, :notes]
      change relate_actor(:user)
    end

    create :create_for_user do
      argument :user_id, :uuid, allow_nil?: false
      accept [:check_in, :check_out, :notes]

      change fn changeset, _context ->
        user_id = Ash.Changeset.get_argument(changeset, :user_id)
        Ash.Changeset.change_attribute(changeset, :user_id, user_id)
      end
    end

    update :update do
      primary? true
      accept [:check_in, :check_out, :notes]
      require_atomic? false

      validate fn changeset, _context ->
        if Date.compare(changeset.data.check_in, Date.utc_today()) == :lt do
          {:error, field: :check_in, message: "cannot edit a past booking"}
        else
          :ok
        end
      end
    end

    destroy :destroy do
      primary? true
      require_atomic? false

      validate fn changeset, _context ->
        if Date.compare(changeset.data.check_in, Date.utc_today()) == :lt do
          {:error, field: :check_in, message: "cannot delete a past booking"}
        else
          :ok
        end
      end
    end
  end

  policies do
    policy action(:read) do
      authorize_if actor_attribute_equals(:is_admin, true)
      authorize_if expr(user_id == ^actor(:id))
    end

    policy action(:for_month) do
      authorize_if always()
    end

    policy action(:for_month_admin) do
      authorize_if actor_attribute_equals(:is_admin, true)
    end

    policy action(:create) do
      authorize_if actor_present()
    end

    policy action(:create_for_user) do
      authorize_if actor_attribute_equals(:is_admin, true)
    end

    policy action(:update) do
      authorize_if actor_attribute_equals(:is_admin, true)
      authorize_if expr(user_id == ^actor(:id))
    end

    policy action(:destroy) do
      authorize_if actor_attribute_equals(:is_admin, true)
      authorize_if expr(user_id == ^actor(:id))
    end
  end
end
