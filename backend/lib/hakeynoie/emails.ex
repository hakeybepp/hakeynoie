defmodule Hakeynoie.Emails do
  import Swoosh.Email

  def booking_notification(booking) do
    admin_email = Application.get_env(:hakeynoie, :admin_email)
    from_email = Application.get_env(:hakeynoie, :from_email, "noreply@hakeynoie")

    if is_nil(admin_email) do
      :skip
    else
      guest = booking.guest_name || "Unknown"
      check_in = Date.to_iso8601(booking.check_in)
      check_out = Date.to_iso8601(booking.check_out)
      notes = if booking.notes && booking.notes != "", do: "\nNotes: #{booking.notes}", else: ""

      body = """
      New booking received.

      Guest: #{guest}
      Check-in:  #{check_in}
      Check-out: #{check_out}#{notes}
      """

      email =
        new()
        |> to(admin_email)
        |> from({"Hakeynoie", from_email})
        |> subject("New booking — #{guest}, #{check_in} → #{check_out}")
        |> text_body(body)

      {:ok, email}
    end
  end
end
