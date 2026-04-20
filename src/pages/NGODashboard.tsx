import { LISTINGS, NGOS } from "@/data/mock";
import { Heart, MapPin, TrendingUp, Users, Calendar } from "lucide-react";
import { RoleHeader } from "./ConsumerDashboard";

export default function NGODashboard() {
  const incoming = LISTINGS.filter((l) => l.stage === "urgent").slice(0, 4);
  const beneficiaries = 12_840;

  return (
    <div className="container py-10">
      <RoleHeader role="NGO" name="Akshaya Patra" subtitle="Bengaluru kitchen · partner since Mar 2025" />

      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Stat icon={Heart} label="Beneficiaries served (lifetime)" value={beneficiaries.toLocaleString("en-IN")} />
        <Stat icon={Users} label="Volunteers in network" value="412" />
        <Stat icon={TrendingUp} label="Kg received this month" value="6,420" />
        <Stat icon={Calendar} label="Pickups scheduled today" value="18" />
      </div>

      <div className="mt-10 grid gap-8 lg:grid-cols-[1fr_360px]">
        <section>
          <h2 className="font-serif text-2xl text-primary">Incoming pickup queue</h2>
          <div className="mt-4 space-y-3">
            {incoming.map((l) => (
              <div key={l.id} className="rounded-xl border border-border bg-cream-light p-5 flex items-center gap-4 flex-wrap">
                <div className="flex-1 min-w-[200px]">
                  <p className="font-serif text-lg text-primary">{l.name}</p>
                  <p className="text-xs text-muted-foreground flex items-center gap-1 mt-1">
                    <MapPin className="h-3 w-3" /> {l.seller} · {l.address}
                  </p>
                </div>
                <div className="text-sm text-muted-foreground">{l.qtyKg} kg · ~{l.servings} meals</div>
                <div className="text-xs text-cascade-urgent">ETA 12 min</div>
                <button className="rounded-full bg-primary text-primary-foreground px-4 py-2 text-xs hover:bg-indigo-deep transition-colors">
                  Confirm receipt
                </button>
              </div>
            ))}
          </div>

          {/* Weekly heatmap of need */}
          <div className="mt-10 rounded-2xl border border-border bg-cream-light p-6">
            <h3 className="font-serif text-xl text-primary">Weekly need heatmap</h3>
            <p className="text-sm text-muted-foreground mt-1">Beneficiary demand vs pickups served, by zone.</p>
            <div className="mt-5 grid grid-cols-7 gap-1.5">
              {Array.from({ length: 7 * 6 }).map((_, i) => {
                const intensity = Math.random();
                return (
                  <div
                    key={i}
                    className="aspect-square rounded-sm"
                    style={{ background: `hsl(36 78% ${85 - intensity * 50}%)` }}
                    title={`Need: ${Math.round(intensity * 100)}%`}
                  />
                );
              })}
            </div>
            <div className="mt-3 flex items-center gap-3 text-[10px] uppercase tracking-widest text-muted-foreground">
              <span>Low need</span>
              <div className="flex-1 h-1 rounded-full bg-gradient-to-r from-ochre/10 to-ochre" />
              <span>High need</span>
            </div>
          </div>
        </section>

        <aside className="space-y-4">
          <div className="rounded-2xl border border-border bg-primary text-primary-foreground p-5">
            <p className="text-xs uppercase tracking-widest text-cream/70">Today at a glance</p>
            <div className="mt-4 space-y-3 text-sm">
              <Row label="Meals served" v="3,240" />
              <Row label="Kg received" v="486" />
              <Row label="Active volunteers" v="29" />
              <Row label="Pending pickups" v="7" />
            </div>
          </div>

          <div className="rounded-2xl border border-border bg-cream-light p-5">
            <p className="text-xs uppercase tracking-widest text-muted-foreground">Partner NGOs in network</p>
            <ul className="mt-3 space-y-2 text-sm">
              {NGOS.filter((n) => n.partner).map((n) => (
                <li key={n.name} className="flex items-baseline justify-between">
                  <span className="text-primary">{n.name}</span>
                  <span className="text-xs text-muted-foreground tabular-nums">{(n.beneficiaries / 1e6).toFixed(2)}M</span>
                </li>
              ))}
            </ul>
          </div>
        </aside>
      </div>
    </div>
  );
}

function Stat({ icon: Icon, label, value }: { icon: any; label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-border bg-cream-light p-5">
      <Icon className="h-5 w-5 text-ochre" />
      <p className="mt-3 text-xs uppercase tracking-widest text-muted-foreground">{label}</p>
      <p className="mt-1 font-serif text-3xl text-primary">{value}</p>
    </div>
  );
}

function Row({ label, v }: { label: string; v: string }) {
  return (
    <div className="flex items-baseline justify-between border-b border-cream/10 pb-2 last:border-0 last:pb-0">
      <span className="text-cream/70">{label}</span>
      <span className="font-serif text-2xl">{v}</span>
    </div>
  );
}
