import apiClient from "./client";

export interface BookingSummary {
  id: string;
  check_in: string;
  check_out: string;
  notes: string | null;
}

export interface UserOut {
  id: string;
  email: string;
  full_name: string;
  is_admin: boolean;
  created_at: string;
  bookings: BookingSummary[];
}

export async function fetchUsers(): Promise<UserOut[]> {
  return apiClient<UserOut[]>("/users");
}

export async function deleteUser(id: string): Promise<void> {
  return apiClient<void>(`/users/${id}`, { method: "DELETE" });
}

export async function resetUserPassword(id: string, password: string): Promise<void> {
  return apiClient<void>(`/users/${id}/password`, {
    method: "PATCH",
    body: JSON.stringify({ password }),
  });
}
