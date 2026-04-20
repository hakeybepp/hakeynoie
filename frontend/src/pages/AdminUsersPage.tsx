import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useUsers, useDeleteUser, useResetUserPassword } from "../hooks/useUsers";

function PasswordResetForm({ userId, onDone }: { userId: string; onDone: () => void }) {
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const resetPassword = useResetUserPassword();
  const { t } = useTranslation();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      await resetPassword.mutateAsync({ id: userId, password });
      setSuccess(true);
      setPassword("");
      setTimeout(onDone, 1200);
    } catch {
      setError(t("adminUsers.resetPasswordError"));
    }
  }

  if (success) {
    return (
      <p className="text-sm text-teal-600 font-medium">{t("adminUsers.resetPasswordSuccess")}</p>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex items-center gap-2 flex-wrap">
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
        minLength={8}
        placeholder={t("adminUsers.resetPasswordPlaceholder")}
        className="flex-1 min-w-0 px-3 py-1.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
        autoFocus
      />
      <button
        type="submit"
        disabled={resetPassword.isPending}
        className="px-3 py-1.5 bg-teal-600 hover:bg-teal-700 disabled:opacity-60 text-white text-sm font-medium rounded-lg transition-colors cursor-pointer border-0"
      >
        {resetPassword.isPending ? t("adminUsers.resetPasswordSaving") : t("adminUsers.resetPasswordSave")}
      </button>
      <button
        type="button"
        onClick={onDone}
        className="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-600 text-sm font-medium rounded-lg transition-colors cursor-pointer border-0"
      >
        {t("table.cancel")}
      </button>
      {error && <p className="w-full text-xs text-red-600">{error}</p>}
    </form>
  );
}

export default function AdminUsersPage() {
  const { data: users, isLoading, error } = useUsers();
  const deleteUser = useDeleteUser();
  const [resetingId, setResetingId] = useState<string | null>(null);
  const { t } = useTranslation();

  async function handleDelete(id: string, name: string) {
    if (!confirm(t("adminUsers.deleteConfirm", { name }))) return;
    try {
      await deleteUser.mutateAsync(id);
    } catch {
      alert(t("adminUsers.deleteError"));
    }
  }

  return (
    <div className="max-w-5xl mx-auto px-6 py-12">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-800 mb-2">{t("adminUsers.title")}</h1>
        <p className="text-slate-500 text-sm">{t("adminUsers.subtitle")}</p>
      </div>

      {isLoading && <div className="text-slate-500 text-sm">{t("admin.loading")}</div>}
      {error && (
        <div className="px-4 py-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg">
          {t("admin.error")}
        </div>
      )}

      {users && (
        <div className="space-y-4">
          {users.map((u) => (
            <div key={u.id} className="bg-white border border-slate-200 rounded-xl shadow-sm p-5">
              <div className="flex items-start justify-between gap-4">
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="font-semibold text-slate-800">{u.full_name}</span>
                    {u.is_admin && (
                      <span className="text-xs bg-teal-100 text-teal-700 px-2 py-0.5 rounded-full font-medium">
                        {t("adminUsers.admin")}
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-slate-500 mb-1">{u.email}</p>
                  <p className="text-xs text-slate-400 font-mono truncate">{u.id}</p>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <button
                    onClick={() => setResetingId(resetingId === u.id ? null : u.id)}
                    className="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-600 text-sm font-medium rounded-lg transition-colors cursor-pointer border-0"
                  >
                    {t("adminUsers.resetPassword")}
                  </button>
                  {!u.is_admin && (
                    <button
                      onClick={() => handleDelete(u.id, u.full_name)}
                      className="px-3 py-2 bg-red-50 hover:bg-red-100 text-red-600 text-sm font-medium rounded-lg transition-colors cursor-pointer border-0"
                    >
                      {t("table.delete")}
                    </button>
                  )}
                </div>
              </div>

              {resetingId === u.id && (
                <div className="mt-4 border-t border-slate-100 pt-4">
                  <p className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-2">
                    {t("adminUsers.resetPassword")}
                  </p>
                  <PasswordResetForm userId={u.id} onDone={() => setResetingId(null)} />
                </div>
              )}

              {u.bookings.length > 0 ? (
                <div className="mt-4 border-t border-slate-100 pt-4">
                  <p className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-2">
                    {t("adminUsers.bookings")}
                  </p>
                  <div className="space-y-1">
                    {u.bookings.map((b) => (
                      <div key={b.id} className="text-sm text-slate-600 flex items-center gap-2">
                        <span className="text-teal-600 font-medium">{b.check_in}</span>
                        <span className="text-slate-400">→</span>
                        <span className="text-teal-600 font-medium">{b.check_out}</span>
                        {b.notes && <span className="text-slate-400 truncate">· {b.notes}</span>}
                      </div>
                    ))}
                  </div>
                </div>
              ) : (
                <div className="mt-4 border-t border-slate-100 pt-4">
                  <p className="text-xs text-slate-400">{t("adminUsers.noBookings")}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
