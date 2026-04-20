import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";

export default function NotFoundPage() {
  const { t } = useTranslation();

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-4">
      <div className="text-center">
        <p className="text-6xl font-bold text-teal-600 mb-4">404</p>
        <h1 className="text-2xl font-semibold text-slate-800 mb-2">{t("notFound.title")}</h1>
        <p className="text-slate-500 text-sm mb-8">{t("notFound.subtitle")}</p>
        <Link
          to="/book"
          className="bg-teal-600 hover:bg-teal-700 text-white font-medium px-6 py-2.5 rounded-lg transition-colors no-underline text-sm"
        >
          {t("notFound.back")}
        </Link>
      </div>
    </div>
  );
}
