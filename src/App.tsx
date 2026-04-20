import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import SiteLayout from "./components/SiteLayout";
import Landing from "./pages/Landing";
import HeatmapPage from "./pages/HeatmapPage";
import ConsumerDashboard from "./pages/ConsumerDashboard";
import SellerDashboard from "./pages/SellerDashboard";
import VolunteerDashboard from "./pages/VolunteerDashboard";
import NGODashboard from "./pages/NGODashboard";
import GiversDirectory from "./pages/GiversDirectory";
import ImpactPage from "./pages/ImpactPage";
import EventsPage from "./pages/EventsPage";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Routes>
          <Route element={<SiteLayout />}>
            <Route path="/" element={<Landing />} />
            <Route path="/map" element={<HeatmapPage />} />
            <Route path="/consumer" element={<ConsumerDashboard />} />
            <Route path="/seller" element={<SellerDashboard />} />
            <Route path="/volunteer" element={<VolunteerDashboard />} />
            <Route path="/ngo" element={<NGODashboard />} />
            <Route path="/givers" element={<GiversDirectory />} />
            <Route path="/impact" element={<ImpactPage />} />
            <Route path="/events" element={<EventsPage />} />
          </Route>
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
