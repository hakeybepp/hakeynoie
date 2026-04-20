import { useState } from "react";
import Calendar from "react-calendar";
import "react-calendar/dist/Calendar.css";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import type { AdminBookingOut } from "../api/bookings";
import { useAuth } from "../context/AuthContext";
import { useAdminMonthBookings, useAvailability } from "../hooks/useBookings";

function toMonthString(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  return `${y}-${m}`;
}

const LOCALE_MAP: Record<string, string> = {
  en: "en-US",
  fr: "fr-FR",
  ja: "ja-JP",
};

const GUEST_COLORS = [
  "#0d9488",
  "#3b82f6",
  "#8b5cf6",
  "#f97316",
  "#ec4899",
  "#eab308",
  "#06b6d4",
  "#22c55e",
  "#dc2626",
  "#6366f1",
];

function buildDateMap(bookings: AdminBookingOut[]): Record<string, AdminBookingOut> {
  const map: Record<string, AdminBookingOut> = {};
  for (const b of bookings) {
    let current = new Date(b.check_in + "T00:00:00");
    const end = new Date(b.check_out + "T00:00:00");
    while (current < end) {
      map[current.toISOString().slice(0, 10)] = b;
      current = new Date(current.getTime() + 86400000);
    }
  }
  return map;
}

function buildColorMap(bookings: AdminBookingOut[]): Record<string, string> {
  const map: Record<string, string> = {};
  let idx = 0;
  for (const b of bookings) {
    if (!map[b.user_id]) {
      map[b.user_id] = GUEST_COLORS[idx % GUEST_COLORS.length];
      idx++;
    }
  }
  return map;
}

function safeClass(userId: string) {
  return "tg" + userId.replace(/-/g, "");
}

function AdminCalendar({ activeStartDate, onMonthChange, locale }: {
  activeStartDate: Date;
  onMonthChange: (d: Date) => void;
  locale: string;
}) {
  const { t } = useTranslation();
  const month = toMonthString(activeStartDate);
  const { data: bookings = [] } = useAdminMonthBookings(month);

  const dateMap = buildDateMap(bookings);
  const colorMap = buildColorMap(bookings);

  // Unique guests in this month
  const guests = Array.from(
    new Map(bookings.map((b) => [b.user_id, b.guest_name])).entries()
  ).map(([user_id, guest_name]) => ({ user_id, guest_name }));

  const styleRules = guests
    .map((g) => {
      const color = colorMap[g.user_id];
      return `.${safeClass(g.user_id)} { background-color: ${color} !important; color: white !important; border-radius: 0.375rem; }`;
    })
    .join("\n");

  function tileClassName({ date, view }: { date: Date; view: string }) {
    if (view !== "month") return null;
    const iso = date.toISOString().slice(0, 10);
    const booking = dateMap[iso];
    if (!booking) return null;
    return safeClass(booking.user_id);
  }

  return (
    <div className="flex flex-wrap gap-6 items-start">
      <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm flex-1 min-w-0">
        <style>{styleRules}</style>
        <Calendar
          tileClassName={tileClassName}
          locale={locale}
          minDate={new Date(2025, 0, 1)}
          onActiveStartDateChange={({ activeStartDate: d }) => {
            if (d) onMonthChange(d);
          }}
        />
      </div>
      <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm w-full sm:w-48 sm:shrink-0">
        <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-3">
          {t("calendar.guests")}
        </p>
        {guests.length === 0 ? (
          <p className="text-xs text-slate-400">{t("calendar.noGuests")}</p>
        ) : (
          <ul className="space-y-2">
            {guests.map((g) => (
              <li key={g.user_id} className="flex items-center gap-2 text-sm text-slate-700">
                <span
                  className="inline-block w-3 h-3 rounded-sm shrink-0"
                  style={{ backgroundColor: colorMap[g.user_id] }}
                />
                {g.guest_name}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}

function UserCalendar({ activeStartDate, onMonthChange, locale }: {
  activeStartDate: Date;
  onMonthChange: (d: Date) => void;
  locale: string;
}) {
  const { t } = useTranslation();
  const { user } = useAuth();
  const navigate = useNavigate();
  const month = toMonthString(activeStartDate);
  const { data: occupiedDays = [] } = useAvailability(month);

  function tileClassName({ date, view }: { date: Date; view: string }) {
    if (view !== "month") return null;
    const iso = date.toISOString().slice(0, 10);
    return occupiedDays.includes(iso) ? "occupied-day" : null;
  }

  return (
    <div>
      <div className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
        <Calendar
          tileClassName={tileClassName}
          locale={locale}
          minDate={new Date(2025, 0, 1)}
          onActiveStartDateChange={({ activeStartDate: d }) => {
            if (d) onMonthChange(d);
          }}
        />
        <div className="mt-3 flex items-center gap-2 text-xs text-slate-500">
          <span className="inline-block w-3 h-3 rounded bg-red-200" />
          {t("calendar.unavailable")}
        </div>
      </div>
      {user && (
        <div className="mt-4">
          <button
            onClick={() => navigate("/book")}
            className="w-full bg-teal-600 hover:bg-teal-700 text-white font-medium py-2.5 rounded-lg transition-colors cursor-pointer border-0"
          >
            {t("calendar.bookAStay")}
          </button>
        </div>
      )}
    </div>
  );
}

export default function CalendarView() {
  const [activeStartDate, setActiveStartDate] = useState(new Date());
  const { user } = useAuth();
  const { i18n } = useTranslation();
  const locale = LOCALE_MAP[i18n.language] ?? "en-US";

  if (user?.is_admin) {
    return (
      <AdminCalendar
        activeStartDate={activeStartDate}
        onMonthChange={setActiveStartDate}
        locale={locale}
      />
    );
  }

  return (
    <UserCalendar
      activeStartDate={activeStartDate}
      onMonthChange={setActiveStartDate}
      locale={locale}
    />
  );
}
