import apiClient from "./client";

export interface BookingHistoryEntry {
  id: string;
  booking_id: string | null;
  user_id: string;
  changed_by_id: string;
  action: "create" | "update" | "delete";
  snapshot: {
    check_in: string;
    check_out: string;
    notes?: string;
  };
  performed_by: string;
  inserted_at: string;
}

export interface BookingOut {
  id: string;
  user_id: string;
  check_in: string;
  check_out: string;
  notes: string | null;
  created_at: string;
  guest_name: string;
}

export interface AdminBookingOut {
  id: string;
  check_in: string;
  check_out: string;
  guest_name: string;
  user_id: string;
  notes: string | null;
}

export async function fetchBookings(): Promise<BookingOut[]> {
  return apiClient<BookingOut[]>("/bookings");
}

export async function fetchAvailability(month: string): Promise<string[]> {
  return apiClient<string[]>(`/bookings/availability?month=${month}`);
}

export async function fetchAdminMonthBookings(month: string): Promise<AdminBookingOut[]> {
  return apiClient<AdminBookingOut[]>(`/bookings/admin_month?month=${month}`);
}

export interface CreateBookingData {
  check_in: string;
  check_out: string;
  notes?: string;
  user_id?: string;
}

export async function createBooking(data: CreateBookingData): Promise<BookingOut> {
  return apiClient<BookingOut>("/bookings", {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function updateBooking(
  id: string,
  data: { check_in?: string; check_out?: string; notes?: string },
): Promise<BookingOut> {
  return apiClient<BookingOut>(`/bookings/${id}`, {
    method: "PATCH",
    body: JSON.stringify(data),
  });
}

export async function deleteBooking(id: string): Promise<void> {
  return apiClient<void>(`/bookings/${id}`, { method: "DELETE" });
}

export async function fetchBookingHistory(): Promise<BookingHistoryEntry[]> {
  return apiClient<BookingHistoryEntry[]>("/bookings/history");
}
