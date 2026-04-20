import { useTranslation } from "react-i18next";
import BookingTable from "../components/BookingTable";
import { useBookingHistory, useBookings } from "../hooks/useBookings";

export default function MyBookingsPage() {
  const { t } = useTranslation();
  const { data: bookings = [], isLoading, isError } = useBookings();
  const { data: history = [] } = useBookingHistory();

  return (
    <div className="max-w-5xl mx-auto px-6 py-12">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-800 mb-2">{t("myBookings.title")}</h1>
        <p className="text-slate-500 text-sm">{t("myBookings.subtitle")}</p>
      </div>

      {isLoading && <p className="text-slate-500 text-sm">{t("admin.loading")}</p>}
      {isError && <p className="text-red-600 text-sm">{t("admin.error")}</p>}
      {!isLoading && !isError && bookings.length === 0 && (
        <p className="text-slate-400 text-sm italic">{t("myBookings.empty")}</p>
      )}
      {bookings.length > 0 && <BookingTable bookings={bookings} />}

      <div className="mt-12">
        <h2 className="text-xl font-semibold text-slate-700 mb-4">{t("myBookings.history")}</h2>
        {history.length === 0 ? (
          <p className="text-slate-400 text-sm italic">{t("myBookings.historyEmpty")}</p>
        ) : (
          <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 border-b border-slate-200">
                <tr>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">{t("table.checkIn")}</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">{t("table.checkOut")}</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">{t("table.notes")}</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Action</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">{t("myBookings.performedBy")}</th>
                  <th className="text-left px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {history.map((h) => (
                  <tr key={h.id}>
                    <td className="px-4 py-3 text-slate-700">{h.snapshot.check_in}</td>
                    <td className="px-4 py-3 text-slate-700">{h.snapshot.check_out}</td>
                    <td className="px-4 py-3 text-slate-500">{h.snapshot.notes || "—"}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-block text-xs font-medium px-2 py-0.5 rounded-full ${
                        h.action === "create" ? "bg-teal-100 text-teal-700" :
                        h.action === "update" ? "bg-blue-100 text-blue-700" :
                        "bg-red-100 text-red-700"
                      }`}>
                        {t(`myBookings.historyAction.${h.action}`)}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-slate-500 text-sm">
                      {h.performed_by === "self" ? t("myBookings.performedBySelf") : t("myBookings.performedByAdmin")}
                    </td>
                    <td className="px-4 py-3 text-slate-400 text-xs">{new Date(h.inserted_at).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
