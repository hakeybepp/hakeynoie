defmodule Hakeynoie.Accounts.Token do
  use Ash.Resource,
    domain: Hakeynoie.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  postgres do
    table "tokens"
    repo Hakeynoie.Repo
  end

  actions do
    defaults [:read, :destroy]
  end
end
