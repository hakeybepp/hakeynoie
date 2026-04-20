defmodule Hakeynoie.Repo do
  use AshPostgres.Repo,
    otp_app: :hakeynoie

  def installed_extensions do
    ["uuid-ossp", "citext", "btree_gist"]
  end
end
