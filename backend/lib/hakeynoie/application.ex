defmodule Hakeynoie.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Hakeynoie.Repo,
      {Phoenix.PubSub, name: Hakeynoie.PubSub},
      HakeynoieWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Hakeynoie.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    HakeynoieWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
