defmodule Hakeynoie.Accounts.User do
  use Ash.Resource,
    domain: Hakeynoie.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  postgres do
    table "users"
    repo Hakeynoie.Repo
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
        confirmation_required? false
        register_action_accept [:full_name]
      end
    end

    tokens do
      enabled? true
      token_resource Hakeynoie.Accounts.Token
      require_token_presence_for_authentication? false
      token_lifetime {90, :days}

      signing_secret fn _resource, _context ->
        case Application.fetch_env(:hakeynoie, :token_signing_secret) do
          {:ok, secret} -> {:ok, secret}
          :error -> {:error, "token_signing_secret not configured"}
        end
      end
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :full_name, :string do
      allow_nil? false
      public? true
    end

    attribute :is_admin, :boolean do
      default false
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string do
      allow_nil? true
      sensitive? true
    end

    attribute :deleted_at, :utc_datetime_usec do
      allow_nil? true
      public? false
    end

    create_timestamp :created_at
  end

  relationships do
    has_many :bookings, Hakeynoie.Bookings.Booking do
      domain Hakeynoie.Bookings
    end
  end

  resource do
    base_filter expr(is_nil(deleted_at))
  end

  actions do
    read :read do
      primary? true
    end

    read :read_with_bookings do
      prepare build(load: [:bookings])
    end

    read :by_email do
      argument :email, :ci_string, allow_nil?: false
      get? true
      filter expr(email == ^arg(:email))
    end

    destroy :destroy do
      primary? true
    end

    update :soft_delete do
      accept []
      require_atomic? false

      change fn changeset, _context ->
        Ash.Changeset.force_change_attribute(changeset, :deleted_at, DateTime.utc_now())
      end
    end

    update :reset_password do
      accept []
      require_atomic? false
      argument :password, :string, allow_nil?: false, sensitive?: true

      change fn changeset, _context ->
        password = Ash.Changeset.get_argument(changeset, :password)
        {:ok, hashed} = AshAuthentication.BcryptProvider.hash(password)
        Ash.Changeset.force_change_attribute(changeset, :hashed_password, hashed)
      end
    end
  end

  identities do
    identity :unique_email, [:email]
  end
end
