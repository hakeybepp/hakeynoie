import { useState } from "react";
import { useTranslation } from "react-i18next";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const LANGUAGES = [
  { code: "en", label: "EN" },
  { code: "fr", label: "FR" },
  { code: "ja", label: "JP" },
];

export default function Navbar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const [menuOpen, setMenuOpen] = useState(false);

  function handleLogout() {
    logout();
    navigate("/");
    setMenuOpen(false);
  }

  function changeLanguage(code: string) {
    i18n.changeLanguage(code);
    localStorage.setItem("lang", code);
  }

  const linkClass = "text-sm font-medium text-slate-600 hover:text-teal-700 no-underline transition-colors";

  return (
    <nav className="bg-white border-b border-slate-200 sticky top-0 z-10">
      <div className="max-w-5xl mx-auto px-6 h-14 flex items-center gap-6">
        <Link to="/" className="text-teal-700 font-semibold text-lg tracking-tight no-underline">
          Hakeynoie
        </Link>
        <div className="flex-1" />

        {/* Language switcher — always visible */}
        <div className="flex items-center gap-1 border border-slate-200 rounded-full px-1 py-0.5">
          {LANGUAGES.map((lang) => (
            <button
              key={lang.code}
              onClick={() => changeLanguage(lang.code)}
              className={`text-xs font-medium px-2 py-0.5 rounded-full transition-colors cursor-pointer border-0 ${
                i18n.language === lang.code
                  ? "bg-teal-600 text-white"
                  : "text-slate-500 hover:text-slate-800 bg-transparent"
              }`}
            >
              {lang.label}
            </button>
          ))}
        </div>

        {/* Desktop nav */}
        <div className="hidden sm:flex items-center gap-6">
          {user ? (
            <>
              <Link to="/book" className={linkClass}>{t("nav.bookAStay")}</Link>
              {!user.is_admin && (
                <Link to="/my-bookings" className={linkClass}>{t("nav.myBookings")}</Link>
              )}
              {user.is_admin && (
                <>
                  <Link to="/admin" className={linkClass}>{t("nav.admin")}</Link>
                  <Link to="/admin/users" className={linkClass}>{t("nav.users")}</Link>
                </>
              )}
              <button onClick={handleLogout} className="text-sm font-medium text-slate-500 hover:text-red-600 transition-colors bg-transparent border-0 cursor-pointer p-0">
                {t("nav.logout")}
              </button>
            </>
          ) : (
            <>
              <Link to="/login" className={linkClass}>{t("nav.login")}</Link>
              <Link to="/register" className="text-sm font-medium bg-teal-600 hover:bg-teal-700 text-white px-4 py-1.5 rounded-full no-underline transition-colors">
                {t("nav.register")}
              </Link>
            </>
          )}
        </div>

        {/* Mobile hamburger */}
        <button
          className="sm:hidden flex flex-col gap-1 cursor-pointer border-0 bg-transparent p-1"
          onClick={() => setMenuOpen((o) => !o)}
          aria-label="Toggle menu"
        >
          <span className={`block w-5 h-0.5 bg-slate-600 transition-transform ${menuOpen ? "translate-y-1.5 rotate-45" : ""}`} />
          <span className={`block w-5 h-0.5 bg-slate-600 transition-opacity ${menuOpen ? "opacity-0" : ""}`} />
          <span className={`block w-5 h-0.5 bg-slate-600 transition-transform ${menuOpen ? "-translate-y-1.5 -rotate-45" : ""}`} />
        </button>
      </div>

      {/* Mobile menu */}
      {menuOpen && (
        <div className="sm:hidden border-t border-slate-100 bg-white px-6 py-4 flex flex-col gap-4">
          {user ? (
            <>
              <Link to="/book" className={linkClass} onClick={() => setMenuOpen(false)}>{t("nav.bookAStay")}</Link>
              {!user.is_admin && (
                <Link to="/my-bookings" className={linkClass} onClick={() => setMenuOpen(false)}>{t("nav.myBookings")}</Link>
              )}
              {user.is_admin && (
                <>
                  <Link to="/admin" className={linkClass} onClick={() => setMenuOpen(false)}>{t("nav.admin")}</Link>
                  <Link to="/admin/users" className={linkClass} onClick={() => setMenuOpen(false)}>{t("nav.users")}</Link>
                </>
              )}
              <button onClick={handleLogout} className="text-sm font-medium text-slate-500 hover:text-red-600 transition-colors bg-transparent border-0 cursor-pointer p-0 text-left">
                {t("nav.logout")}
              </button>
            </>
          ) : (
            <>
              <Link to="/login" className={linkClass} onClick={() => setMenuOpen(false)}>{t("nav.login")}</Link>
              <Link to="/register" className="text-sm font-medium text-teal-600 hover:text-teal-700 no-underline transition-colors" onClick={() => setMenuOpen(false)}>
                {t("nav.register")}
              </Link>
            </>
          )}
        </div>
      )}
    </nav>
  );
}
