# Script for populating the database with sample development data.
# Run with: mix run priv/repo/seeds.exs

alias Hakeynoie.Accounts.User
alias Hakeynoie.Bookings.Booking

today = Date.utc_today()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

create_user = fn attrs ->
  defaults = %{password: "Password123!"}

  User
  |> Ash.Changeset.for_create(:register_with_password, Map.merge(defaults, attrs))
  |> Ash.create!(authorize?: false, domain: Hakeynoie.Accounts)
end

make_admin = fn user ->
  Hakeynoie.Repo.query!(
    "UPDATE users SET is_admin = true WHERE id = $1",
    [Ecto.UUID.dump!(user.id)]
  )

  Ash.get!(User, user.id, authorize?: false, domain: Hakeynoie.Accounts)
end

create_booking = fn user, check_in_offset, check_out_offset, notes ->
  Booking
  |> Ash.Changeset.for_create(
    :create,
    %{
      check_in: Date.add(today, check_in_offset),
      check_out: Date.add(today, check_out_offset),
      notes: notes
    },
    actor: user,
    authorize?: false
  )
  |> Ash.create!(domain: Hakeynoie.Bookings, authorize?: false)
end

# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------

IO.puts("Creating users...")

admin =
  create_user.(%{
    email: "admin@example.com",
    full_name: "Admin User"
  })
  |> make_admin.()

alice = create_user.(%{email: "alice@example.com", full_name: "Alice Martin"})
bob = create_user.(%{email: "bob@example.com", full_name: "Bob Chen"})
carol = create_user.(%{email: "carol@example.com", full_name: "Carol Osei"})

IO.puts("  admin@example.com  (admin)")
IO.puts("  alice@example.com")
IO.puts("  bob@example.com")
IO.puts("  carol@example.com")

# ---------------------------------------------------------------------------
# Bookings
# Constraint: no two bookings may have overlapping date ranges (btree_gist
# EXCLUDE constraint on the whole table, not per-user). All intervals below
# are non-overlapping.
#
# Layout (offsets from today):
#   [-50, -44)  past   — alice
#   [-40, -35)  past   — bob
#   [-30, -25)  past   — carol
#   [-20, -15)  past   — alice (second past stay)
#   [ -5,  -1)  recent — bob   (checked out yesterday)
#   [  2,   6)  soon   — carol
#   [  8,  13)  soon   — alice
#   [ 15,  20)  future — bob
#   [ 22,  27)  future — admin
#   [ 30,  36)  future — carol (longer stay)
# ---------------------------------------------------------------------------

IO.puts("\nCreating bookings...")

create_booking.(alice, -50, -44, "Annual retreat")
create_booking.(bob, -40, -35, nil)
create_booking.(carol, -30, -25, "Team off-site")
create_booking.(alice, -20, -15, "Quick getaway")
create_booking.(bob, -5, -1, "Weekend break")
create_booking.(carol, 2, 6, nil)
create_booking.(alice, 8, 13, "Spring holiday")
create_booking.(bob, 15, 20, "Conference stay")
create_booking.(admin, 22, 27, "Admin inspection visit")
create_booking.(carol, 30, 36, "Extended family trip")

IO.puts("  10 bookings created (past, current-week, and future)")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

IO.puts("""

Done! Sample data loaded.

  Password for all accounts: Password123!

  Upcoming bookings (relative to #{today}):
    carol  #{Date.add(today, 2)} → #{Date.add(today, 6)}
    alice  #{Date.add(today, 8)} → #{Date.add(today, 13)}
    bob    #{Date.add(today, 15)} → #{Date.add(today, 20)}
    admin  #{Date.add(today, 22)} → #{Date.add(today, 27)}
    carol  #{Date.add(today, 30)} → #{Date.add(today, 36)}
""")
