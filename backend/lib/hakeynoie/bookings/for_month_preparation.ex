defmodule Hakeynoie.Bookings.ForMonthPreparation do
  use Ash.Resource.Preparation
  require Ash.Query

  @impl true
  def prepare(query, _opts, _context) do
    month_str = Ash.Query.get_argument(query, :month)

    case Date.from_iso8601("#{month_str}-01") do
      {:ok, first_day} ->
        last_day = Date.end_of_month(first_day)
        next_day = Date.add(last_day, 1)
        Ash.Query.filter(query, check_in < ^next_day and check_out > ^first_day)

      _ ->
        Ash.Query.add_error(query, field: :month, message: "invalid format, use YYYY-MM")
    end
  end
end
