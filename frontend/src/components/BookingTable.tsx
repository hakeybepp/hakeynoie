import { useState } from "react";
import { useTranslation } from "react-i18next";
import type { BookingOut } from "../api/bookings";
import { useDeleteBooking, useUpdateBooking } from "../hooks/useBookings";

interface Props {
  bookings: BookingOut[];
}

interface EditState {
  check_in: string;
  check_out: string;
  notes: string;
}

export default function BookingTable({ bookings }: Props) {
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editState, setEditState] = useState<EditState>({ check_in: "", check_out: "", notes: "" });
  const [error, setError] = useState<string | null>(null);
  const { t } = useTranslation();

  const updateBooking = useUpdateBooking();
  const deleteBooking = useDeleteBooking();

  function startEdit(b: BookingOut) {
    setEditingId(b.id);
    setEditState({ check_in: b.check_in, check_out: b.check_out, notes: b.notes ?? "" });
    setError(null);
  }

  async function saveEdit(id: string) {
    setError(null);
    try {
      await updateBooking.mutateAsync({
        id,
        data: { check_in: editState.check_in, check_out: editState.check_out, notes: editState.notes || undefined },
      });
      setEditingId(null);
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : t("table.updateFailed"));
    }
  }

  async function handleDelete(id: string) {
    if (!confirm(t("table.deleteConfirm"))) return;
    await deleteBooking.mutateAsync(id);
  }

  const inputClass = "px-2 py-1 border border-slate-300 rounded text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 w-full";

  return (
    <div>
      {error && (
        <div className="mb-4 px-3 py-2.5 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg">
          {error}
        </div>
      )}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200">
              {(["table.guest", "table.checkIn", "table.checkOut", "table.notes", "table.actions"] as const).map((key) => (
                <th key={key} className="px-4 py-3 text-left font-semibold text-slate-600 text-xs uppercase tracking-wide">
                  {t(key)}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {bookings.map((b) =>
              editingId === b.id ? (
                <tr key={b.id} className="bg-teal-50">
                  <td className="px-4 py-3 text-slate-700 font-medium">{b.guest_name}</td>
                  <td className="px-4 py-3">
                    <input type="date" value={editState.check_in} onChange={(e) => setEditState((s) => ({ ...s, check_in: e.target.value }))} className={inputClass} />
                  </td>
                  <td className="px-4 py-3">
                    <input type="date" value={editState.check_out} onChange={(e) => setEditState((s) => ({ ...s, check_out: e.target.value }))} className={inputClass} />
                  </td>
                  <td className="px-4 py-3">
                    <input value={editState.notes} onChange={(e) => setEditState((s) => ({ ...s, notes: e.target.value }))} className={inputClass} placeholder="—" />
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex gap-2">
                      <button onClick={() => saveEdit(b.id)} className="px-3 py-1 bg-teal-600 hover:bg-teal-700 text-white text-xs font-medium rounded-md transition-colors cursor-pointer border-0">
                        {t("table.save")}
                      </button>
                      <button onClick={() => setEditingId(null)} className="px-3 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-medium rounded-md transition-colors cursor-pointer border-0">
                        {t("table.cancel")}
                      </button>
                    </div>
                  </td>
                </tr>
              ) : (
                <tr key={b.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 text-slate-800 font-medium">{b.guest_name}</td>
                  <td className="px-4 py-3 text-slate-600">{b.check_in}</td>
                  <td className="px-4 py-3 text-slate-600">{b.check_out}</td>
                  <td className="px-4 py-3 text-slate-500">{b.notes ?? "—"}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-2">
                      {new Date(b.check_in) >= new Date(new Date().toDateString()) && (
                        <button onClick={() => startEdit(b)} className="px-3 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-medium rounded-md transition-colors cursor-pointer border-0">
                          {t("table.edit")}
                        </button>
                      )}
                      {new Date(b.check_in) >= new Date(new Date().toDateString()) && (
                        <button onClick={() => handleDelete(b.id)} className="px-3 py-1 bg-red-50 hover:bg-red-100 text-red-600 text-xs font-medium rounded-md transition-colors cursor-pointer border-0">
                          {t("table.delete")}
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              )
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
