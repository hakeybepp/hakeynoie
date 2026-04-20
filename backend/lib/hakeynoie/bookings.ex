defmodule Hakeynoie.Bookings do
  use Ash.Domain

  resources do
    resource Hakeynoie.Bookings.Booking
    resource Hakeynoie.Bookings.BookingHistory
  end
end
