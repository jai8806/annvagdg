import { SiteHeader, SiteFooter } from "./SiteChrome";
import { Outlet } from "react-router-dom";

export default function SiteLayout() {
  return (
    <div className="min-h-screen flex flex-col bg-background">
      <SiteHeader />
      <main className="flex-1">
        <Outlet />
      </main>
      <SiteFooter />
    </div>
  );
}
