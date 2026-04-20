import { format } from "date-fns";
import { enUS, fr, ja } from "date-fns/locale";
import { useState } from "react";
import { DayPicker } from "react-day-picker";
import "react-day-picker/dist/style.css";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import type { DateRange } from "react-day-picker";
import { ApiError } from "../api/client";
import { useAvailability, useCreateBooking } from "../hooks/useBookings";
import { useUsers } from "../hooks/useUsers";
import { useAuth } from "../context/AuthContext";

function toMonthString(date: Date): string {
  return format(date, "yyyy-MM");
}

const LOCALE_MAP = { en: enUS, fr, ja };

export default function BookingPage() {
  const [month, setMonth] = useState(new Date());
  const [range, setRange] = useState<DateRange | undefined>();
  const [notes, setNotes] = useState("");
  const [selectedUserId, setSelectedUserId] = useState("");
  const [error, setError] = useState<string | null>(null);

  const { t, i18n } = useTranslation();
  const { user } = useAuth();
  const monthStr = toMonthString(month);
  const { data: occupiedDays = [] } = useAvailability(monthStr);
  const { data: users = [] } = useUsers();
  const createBooking = useCreateBooking();
  const navigate = useNavigate();

  const dateFnsLocale = LOCALE_MAP[i18n.language as keyof typeof LOCALE_MAP] ?? enUS;
  const disabledDates = occupiedDays.map((d) => new Date(d + "T00:00:00"));
  const nonAdminUsers = users.filter((u) => !u.is_admin);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (user?.is_admin && !selectedUserId) {
      setError(t("booking.errorSelectUser"));
      return;
    }
    if (!range?.from || !range.to) {
      setError(t("booking.errorNoDates"));
      return;
    }

    const checkIn = format(range.from, "yyyy-MM-dd");
    const checkOut = format(range.to, "yyyy-MM-dd");

    try {
      const result = await createBooking.mutateAsync({
        check_in: checkIn,
        check_out: checkOut,
        notes: notes || undefined,
        user_id: user?.is_admin ? selectedUserId : undefined,
      });
      navigate("/booking-confirmed", { state: { booking: result } });
    } catch (err: unknown) {
      if (err instanceof ApiError && err.status === 409) {
        setError(t("booking.errorOverlap"));
      } else {
        setError(err instanceof Error ? err.message : t("booking.confirm"));
      }
    }
  }

  return (
    <div className="max-w-4xl mx-auto px-6 py-12">
      <div className="mb-8 text-center">
        <h1 className="text-3xl font-bold text-slate-800 mb-2">{t("booking.title")}</h1>
        <p className="text-slate-500 text-sm">{t("booking.subtitle")}</p>
      </div>

      {error && (
        <div className="mb-6 px-4 py-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg max-w-2xl mx-auto">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <div className="flex gap-6 items-start justify-center flex-wrap">
          {/* Calendar */}
          <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-5 shrink-0">
            <DayPicker
              mode="range"
              selected={range}
              onSelect={setRange}
              month={month}
              onMonthChange={setMonth}
              disabled={[{ before: new Date() }, ...disabledDates]}
              modifiers={{ booked: disabledDates }}
              modifiersClassNames={{ booked: "rdp-day_booked" }}
              locale={dateFnsLocale}
            />
          </div>

          {/* Side panel */}
          <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-6 flex flex-col gap-5 w-full sm:w-72 sm:shrink-0">
            {user?.is_admin && (
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">
                  {t("booking.selectUser")}
                </label>
                <select
                  value={selectedUserId}
                  onChange={(e) => setSelectedUserId(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent bg-white"
                >
                  <option value="">{t("booking.selectUserPlaceholder")}</option>
                  {nonAdminUsers.map((u) => (
                    <option key={u.id} value={u.id}>
                      {u.full_name} ({u.email})
                    </option>
                  ))}
                </select>
              </div>
            )}

            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-2">
                {t("booking.selectDates")}
              </p>
              {range?.from && range?.to ? (
                <div className="bg-teal-50 border border-teal-200 rounded-lg px-4 py-3 text-sm text-teal-800 space-y-1">
                  <div className="flex justify-between">
                    <span className="text-teal-600">{t("table.checkIn")}</span>
                    <span className="font-medium">{format(range.from, "MMM d, yyyy", { locale: dateFnsLocale })}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-teal-600">{t("table.checkOut")}</span>
                    <span className="font-medium">{format(range.to, "MMM d, yyyy", { locale: dateFnsLocale })}</span>
                  </div>
                </div>
              ) : (
                <p className="text-sm text-slate-400 italic">—</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                {t("booking.notes")}{" "}
                <span className="text-slate-400 font-normal">({t("booking.notesOptional")})</span>
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                rows={3}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent resize-none"
                placeholder={t("booking.notesPlaceholder")}
              />
            </div>

            <button
              type="submit"
              disabled={createBooking.isPending}
              className="w-full bg-teal-600 hover:bg-teal-700 disabled:opacity-60 text-white font-medium py-2.5 rounded-lg transition-colors cursor-pointer border-0 text-sm"
            >
              {createBooking.isPending ? t("booking.confirming") : t("booking.confirm")}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
}
