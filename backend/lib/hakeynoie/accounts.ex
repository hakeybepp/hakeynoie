defmodule Hakeynoie.Accounts do
  use Ash.Domain

  resources do
    resource Hakeynoie.Accounts.User
    resource Hakeynoie.Accounts.Token
  end
end
