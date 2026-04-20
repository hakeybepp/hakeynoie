defmodule HakeynoieWeb.ErrorJSON do
  def render("404.json", _assigns), do: %{detail: "Not found"}
  def render("401.json", _assigns), do: %{detail: "Unauthorized"}
  def render("403.json", _assigns), do: %{detail: "Forbidden"}
  def render("500.json", _assigns), do: %{detail: "Internal server error"}

  def render(template, _assigns),
    do: %{detail: Phoenix.Controller.status_message_from_template(template)}
end
