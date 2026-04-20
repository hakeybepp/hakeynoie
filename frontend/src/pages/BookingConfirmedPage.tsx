import { useTranslation } from "react-i18next";
import { Link, Navigate, useLocation } from "react-router-dom";
import type { BookingOut } from "../api/bookings";

export default function BookingConfirmedPage() {
  const { t } = useTranslation();
  const { state } = useLocation();
  const booking: BookingOut | undefined = state?.booking;

  if (!booking) return <Navigate to="/book" replace />;

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-teal-100 mb-4">
            <svg className="w-8 h-8 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-slate-800 mb-1">{t("bookingConfirmed.title")}</h1>
          <p className="text-slate-500 text-sm">{t("bookingConfirmed.subtitle")}</p>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-6 space-y-4">
          {booking.guest_name && (
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">{t("bookingConfirmed.bookedFor")}</span>
              <span className="font-medium text-slate-800">{booking.guest_name}</span>
            </div>
          )}
          <div className="flex justify-between text-sm">
            <span className="text-slate-500">{t("bookingConfirmed.checkIn")}</span>
            <span className="font-medium text-slate-800">{booking.check_in}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-slate-500">{t("bookingConfirmed.checkOut")}</span>
            <span className="font-medium text-slate-800">{booking.check_out}</span>
          </div>
          {booking.notes && (
            <div className="flex justify-between text-sm">
              <span className="text-slate-500">{t("bookingConfirmed.notes")}</span>
              <span className="font-medium text-slate-800 text-right max-w-[60%]">{booking.notes}</span>
            </div>
          )}
        </div>

        <div className="mt-6 flex flex-col gap-3">
          <Link
            to="/book"
            className="w-full text-center bg-teal-600 hover:bg-teal-700 text-white font-medium py-2.5 rounded-lg transition-colors no-underline text-sm"
          >
            {t("bookingConfirmed.newBooking")}
          </Link>
          <Link
            to="/my-bookings"
            className="w-full text-center bg-slate-100 hover:bg-slate-200 text-slate-700 font-medium py-2.5 rounded-lg transition-colors no-underline text-sm"
          >
            {t("bookingConfirmed.backToCalendar")}
          </Link>
        </div>
      </div>
    </div>
  );
}
