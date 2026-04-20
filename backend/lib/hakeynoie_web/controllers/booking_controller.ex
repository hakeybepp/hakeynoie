defmodule HakeynoieWeb.BookingController do
  use HakeynoieWeb, :controller

  alias Hakeynoie.Bookings
  alias Hakeynoie.Bookings.Booking

  def availability(conn, %{"month" => month}) do
    result =
      Booking
      |> Ash.Query.for_read(:for_month, %{month: month})
      |> Ash.read(domain: Bookings)

    case result do
      {:ok, bookings} ->
        json(conn, compute_occupied_days(bookings, month))

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{detail: "Invalid month format. Use YYYY-MM"})
    end
  end

  def availability(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{detail: "month parameter is required"})
  end

  def admin_month(conn, %{"month" => month}) do
    actor = conn.assigns.current_user

    result =
      Booking
      |> Ash.Query.for_read(:for_month_admin, %{month: month}, actor: actor, domain: Bookings)
      |> Ash.read(domain: Bookings)

    case result do
      {:ok, bookings} ->
        json(
          conn,
          Enum.map(bookings, fn b ->
            %{
              id: b.id,
              check_in: Date.to_iso8601(b.check_in),
              check_out: Date.to_iso8601(b.check_out),
              guest_name: b.guest_name,
              user_id: b.user_id,
              notes: b.notes
            }
          end)
        )

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{detail: "Invalid month format. Use YYYY-MM"})
    end
  end

  def admin_month(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{detail: "month parameter is required"})
  end

  def index(conn, _params) do
    actor = conn.assigns.current_user

    case Ash.read(Booking, actor: actor, domain: Bookings) do
      {:ok, bookings} ->
        json(conn, Enum.map(bookings, &render_booking/1))

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{detail: "Internal server error"})
    end
  end

  def create(conn, params) do
    actor = conn.assigns.current_user

    attrs = %{
      check_in: params["check_in"],
      check_out: params["check_out"],
      notes: params["notes"]
    }

    result =
      if actor.is_admin && params["user_id"] do
        Ash.create(Booking, Map.put(attrs, :user_id, params["user_id"]),
          action: :create_for_user,
          actor: actor,
          domain: Bookings
        )
      else
        Ash.create(Booking, attrs, actor: actor, domain: Bookings)
      end

    case result do
      {:ok, booking} ->
        booking = Ash.load!(booking, [:user, :guest_name], domain: Bookings)
        record_history(booking, "create", actor, Bookings)
        send_booking_notification(booking)

        conn
        |> put_status(:created)
        |> json(render_booking(booking))

      {:error, error} ->
        if overlap_error?(error) do
          conn
          |> put_status(:conflict)
          |> json(%{detail: "Booking dates overlap with an existing booking"})
        else
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{detail: "Invalid booking data"})
        end
    end
  end

  def update(conn, %{"id" => id} = params) do
    actor = conn.assigns.current_user

    case Ash.get(Booking, id, actor: actor, domain: Bookings) do
      {:error, %Ash.Error.Query.NotFound{}} ->
        conn |> put_status(:not_found) |> json(%{detail: "Booking not found"})

      {:ok, booking} ->
        attrs =
          params
          |> Map.take(["check_in", "check_out", "notes"])
          |> Enum.reject(fn {_k, v} -> is_nil(v) end)
          |> Map.new()

        case Ash.update(booking, attrs, actor: actor, domain: Bookings) do
          {:ok, updated} ->
            updated = Ash.load!(updated, [:user, :guest_name], domain: Bookings)
            record_history(updated, "update", actor, Bookings)
            json(conn, render_booking(updated))

          {:error, error} ->
            if overlap_error?(error) do
              conn
              |> put_status(:conflict)
              |> json(%{detail: "Booking dates overlap with an existing booking"})
            else
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{detail: "Invalid booking data"})
            end
        end

      {:error, _} ->
        conn |> put_status(:not_found) |> json(%{detail: "Booking not found"})
    end
  end

  def delete(conn, %{"id" => id}) do
    actor = conn.assigns.current_user

    case Ash.get(Booking, id, actor: actor, domain: Bookings) do
      {:error, %Ash.Error.Query.NotFound{}} ->
        conn |> put_status(:not_found) |> json(%{detail: "Booking not found"})

      {:ok, booking} ->
        case Ash.destroy(booking, actor: actor, domain: Bookings) do
          :ok ->
            record_history(booking, "delete", actor, Bookings)
            send_resp(conn, :no_content, "")

          {:error, _} ->
            conn |> put_status(:internal_server_error) |> json(%{detail: "Failed to delete"})
        end

      {:error, _} ->
        conn |> put_status(:not_found) |> json(%{detail: "Booking not found"})
    end
  end

  def history(conn, _params) do
    actor = conn.assigns.current_user

    histories =
      if actor.is_admin do
        Hakeynoie.Bookings.BookingHistory
        |> Ash.Query.for_read(:all, %{})
        |> Ash.read!(domain: Bookings, authorize?: false)
      else
        Hakeynoie.Bookings.BookingHistory
        |> Ash.Query.for_read(:for_user, %{user_id: actor.id})
        |> Ash.read!(domain: Bookings, authorize?: false)
      end

    user_name_map =
      if actor.is_admin do
        users =
          Ash.read!(Hakeynoie.Accounts.User,
            domain: Hakeynoie.Accounts,
            authorize?: false
          )

        Map.new(users, fn u -> {u.id, u.full_name} end)
      else
        %{}
      end

    rendered =
      Enum.map(histories, fn h ->
        performed_by =
          if actor.is_admin do
            Map.get(user_name_map, h.changed_by_id, "Unknown")
          else
            if h.changed_by_id == actor.id, do: "self", else: "admin"
          end

        %{
          id: h.id,
          booking_id: h.booking_id,
          user_id: h.user_id,
          changed_by_id: h.changed_by_id,
          action: h.action,
          snapshot: h.snapshot,
          performed_by: performed_by,
          inserted_at: DateTime.to_iso8601(h.inserted_at)
        }
      end)

    json(conn, rendered)
  end

  defp record_history(booking, action, actor, repo) do
    snapshot = %{
      "check_in" => Date.to_iso8601(booking.check_in),
      "check_out" => Date.to_iso8601(booking.check_out),
      "notes" => booking.notes
    }

    Ash.create!(
      Hakeynoie.Bookings.BookingHistory,
      %{
        booking_id: booking.id,
        user_id: booking.user_id,
        changed_by_id: actor.id,
        action: action,
        snapshot: snapshot
      },
      action: :record,
      domain: repo,
      authorize?: false
    )
  end

  defp render_booking(booking) do
    %{
      id: booking.id,
      check_in: Date.to_iso8601(booking.check_in),
      check_out: Date.to_iso8601(booking.check_out),
      notes: booking.notes,
      user_id: booking.user_id,
      guest_name: booking.guest_name,
      created_at: booking.created_at
    }
  end

  defp compute_occupied_days(bookings, month_str) do
    with {:ok, first_day} <- Date.from_iso8601("#{month_str}-01") do
      last_day = Date.end_of_month(first_day)

      bookings
      |> Enum.flat_map(fn booking ->
        start_date = latest_date(booking.check_in, first_day)
        end_date = earliest_date(Date.add(booking.check_out, -1), last_day)

        if Date.compare(start_date, end_date) != :gt do
          date_range(start_date, end_date)
        else
          []
        end
      end)
      |> Enum.map(&Date.to_iso8601/1)
      |> Enum.uniq()
      |> Enum.sort()
    else
      _ -> []
    end
  end

  defp latest_date(a, b), do: if(Date.compare(a, b) == :gt, do: a, else: b)
  defp earliest_date(a, b), do: if(Date.compare(a, b) == :lt, do: a, else: b)

  defp date_range(start_date, end_date) do
    Stream.iterate(start_date, &Date.add(&1, 1))
    |> Stream.take_while(&(Date.compare(&1, end_date) != :gt))
    |> Enum.to_list()
  end

  defp overlap_error?(error) do
    String.contains?(inspect(error), "bookings_no_overlap")
  end

  defp send_booking_notification(booking) do
    case Hakeynoie.Emails.booking_notification(booking) do
      {:ok, email} ->
        Task.start(fn ->
          case Hakeynoie.Mailer.deliver(email) do
            {:ok, _} ->
              :ok

            {:error, reason} ->
              require Logger
              Logger.warning("Failed to send booking notification: #{inspect(reason)}")
          end
        end)

      :skip ->
        :ok
    end
  end
end
