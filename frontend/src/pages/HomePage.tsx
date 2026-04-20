import { useTranslation } from "react-i18next";
import CalendarView from "../components/CalendarView";

export default function HomePage() {
  const { t } = useTranslation();

  return (
    <div className="max-w-5xl mx-auto px-6 py-12">
      <div className="mb-8 text-center">
        <h1 className="text-3xl font-bold text-slate-800 mb-2">{t("home.title")}</h1>
        <p className="text-slate-500">{t("home.subtitle")}</p>
      </div>
      <div className="max-w-lg mx-auto">
        <CalendarView />
      </div>
    </div>
  );
}
