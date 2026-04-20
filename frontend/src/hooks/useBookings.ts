import {
  useMutation,
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";
import {
  createBooking,
  deleteBooking,
  fetchAdminMonthBookings,
  fetchAvailability,
  fetchBookingHistory,
  fetchBookings,
  updateBooking,
} from "../api/bookings";

export function useBookings() {
  return useQuery({
    queryKey: ["bookings"],
    queryFn: fetchBookings,
  });
}

export function useAvailability(month: string) {
  return useQuery({
    queryKey: ["availability", month],
    queryFn: () => fetchAvailability(month),
  });
}

export function useAdminMonthBookings(month: string) {
  return useQuery({
    queryKey: ["adminMonthBookings", month],
    queryFn: () => fetchAdminMonthBookings(month),
  });
}

export function useCreateBooking() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createBooking,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["bookings"] });
      queryClient.invalidateQueries({ queryKey: ["availability"] });
      queryClient.invalidateQueries({ queryKey: ["bookingHistory"] });
    },
  });
}

export function useUpdateBooking() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Parameters<typeof updateBooking>[1] }) =>
      updateBooking(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["bookings"] });
      queryClient.invalidateQueries({ queryKey: ["availability"] });
      queryClient.invalidateQueries({ queryKey: ["bookingHistory"] });
    },
  });
}

export function useDeleteBooking() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteBooking,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["bookings"] });
      queryClient.invalidateQueries({ queryKey: ["availability"] });
      queryClient.invalidateQueries({ queryKey: ["bookingHistory"] });
    },
  });
}

export function useBookingHistory() {
  return useQuery({
    queryKey: ["bookingHistory"],
    queryFn: fetchBookingHistory,
  });
}
