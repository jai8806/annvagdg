import { VOLUNTEERS, TIER_REQS, LISTINGS } from "@/data/mock";
import { Award, MapPin, Shield, Share2, Download, GraduationCap, Trophy, CheckCircle2 } from "lucide-react";
import { RoleHeader } from "./ConsumerDashboard";

export default function VolunteerDashboard() {
  const me = { name: "Karthik", tier: "Silver" as const, rescues: 64, kg: 805, nextTier: "Gold", nextReq: 125 };
  const progress = (me.rescues / me.nextReq) * 100;
  const available = LISTINGS.filter((l) => l.stage === "urgent").slice(0, 4);
  const credentials = LISTINGS.slice(0, 5).map((l, i) => ({
    id: l.id,
    title: l.name,
    seller: l.seller,
    hash: `0x${(Math.random().toString(16).slice(2, 10) + "a4f9b2c8d1e3f5a6")}`.slice(0, 14) + "…",
    ngo: ["Akshaya Patra", "Robin Hood Army", "Feeding India", "Goonj", "Akshaya Patra"][i],
    date: ["Apr 18", "Apr 15", "Apr 12", "Apr 09", "Apr 04"][i],
    kg: [4.2, 8.1, 3.6, 12.4, 5.8][i],
  }));

  return (
    <div className="container py-10">
      <RoleHeader role="Volunteer" name={me.name} subtitle={`${me.tier} tier · Bengaluru chapter`} />

      <div className="mt-8 grid gap-6 lg:grid-cols-3">
        {/* Tier progress */}
        <div className="lg:col-span-1 rounded-2xl border border-border bg-primary text-primary-foreground p-6 relative overflow-hidden">
          <Award className="absolute -right-4 -bottom-4 h-32 w-32 text-cream/5" />
          <p className="text-xs uppercase tracking-widest text-ochre">Current tier</p>
          <p className="mt-2 font-serif text-5xl">{me.tier}</p>
          <p className="mt-1 text-sm text-cream/70">{me.rescues} rescues · {me.kg} kg delivered</p>

          <div className="mt-6">
            <div className="flex justify-between text-xs text-cream/60">
              <span>{me.tier}</span>
              <span>{me.nextTier} · {me.nextReq}</span>
            </div>
            <div className="mt-2 h-2 rounded-full bg-cream/15 overflow-hidden">
              <div className="h-full bg-ochre transition-all" style={{ width: `${progress}%` }} />
            </div>
            <p className="mt-2 text-xs text-cream/70">{me.nextReq - me.rescues} more rescues to {me.nextTier}.</p>
          </div>

          <div className="mt-6 flex gap-2">
            <button className="flex-1 rounded-full bg-cream/10 hover:bg-cream/20 transition-colors py-2 text-xs inline-flex items-center justify-center gap-1.5">
              <Share2 className="h-3.5 w-3.5" /> LinkedIn
            </button>
            <button className="flex-1 rounded-full bg-cream/10 hover:bg-cream/20 transition-colors py-2 text-xs inline-flex items-center justify-center gap-1.5">
              <Download className="h-3.5 w-3.5" /> NCC/NSS
            </button>
          </div>
        </div>

        {/* Available rescues */}
        <div className="lg:col-span-2 rounded-2xl border border-border bg-cream-light p-6">
          <div className="flex items-baseline justify-between">
            <h2 className="font-serif text-2xl text-primary">Rescues near you</h2>
            <span className="text-xs text-muted-foreground">{available.length} urgent · 1.4 km radius</span>
          </div>
          <div className="mt-4 space-y-3">
            {available.map((l) => (
              <div key={l.id} className="flex items-center gap-4 rounded-xl border border-border bg-background p-4">
                <span className="h-2.5 w-2.5 rounded-full bg-cascade-urgent urgency-pulse shrink-0" />
                <div className="flex-1 min-w-0">
                  <p className="text-primary truncate">{l.name}</p>
                  <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
                    <MapPin className="h-3 w-3" /> {l.seller} · {l.address}
                  </p>
                </div>
                <div className="text-right shrink-0">
                  <p className="text-xs text-cascade-urgent">{l.hoursLeft}h left</p>
                  <p className="text-xs text-muted-foreground">{l.qtyKg} kg</p>
                </div>
                <button className="rounded-full bg-primary text-primary-foreground px-4 py-2 text-xs hover:bg-indigo-deep transition-colors shrink-0">
                  Accept
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Verified credentials */}
      <section className="mt-10">
        <div className="flex items-baseline justify-between">
          <div>
            <h2 className="font-serif text-2xl text-primary">Verified credentials wall</h2>
            <p className="text-sm text-muted-foreground mt-1">Every rescue: timestamped, geotagged, NGO-confirmed, hash-anchored.</p>
          </div>
          <Shield className="h-5 w-5 text-ochre" />
        </div>
        <div className="mt-5 grid gap-3 md:grid-cols-2 lg:grid-cols-3">
          {credentials.map((c) => (
            <div key={c.id} className="rounded-xl border border-border bg-cream-light p-5">
              <div className="flex items-center justify-between">
                <CheckCircle2 className="h-5 w-5 text-cascade-fresh" />
                <span className="font-mono text-[10px] text-muted-foreground">{c.hash}</span>
              </div>
              <p className="mt-3 font-serif text-lg text-primary leading-tight">{c.title}</p>
              <p className="text-xs text-muted-foreground mt-0.5">{c.seller}</p>
              <div className="mt-4 pt-4 border-t border-border flex justify-between text-xs">
                <span className="text-muted-foreground">{c.date} · {c.kg} kg</span>
                <span className="text-ochre-deep">→ {c.ngo}</span>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Leaderboard + Training */}
      <section className="mt-10 grid gap-6 lg:grid-cols-2">
        <div className="rounded-2xl border border-border bg-cream-light p-6">
          <div className="flex items-center gap-2">
            <Trophy className="h-5 w-5 text-ochre" />
            <h2 className="font-serif text-2xl text-primary">Bengaluru leaderboard</h2>
          </div>
          <ol className="mt-4 space-y-2">
            {VOLUNTEERS.sort((a, b) => b.rescues - a.rescues).slice(0, 6).map((v, i) => (
              <li key={v.name} className="flex items-center gap-3 text-sm">
                <span className="font-mono text-xs text-muted-foreground w-5">{(i + 1).toString().padStart(2, "0")}</span>
                <span className="flex-1 text-primary">{v.name}</span>
                <span className="text-xs text-muted-foreground">{v.tier}</span>
                <span className="font-mono text-primary tabular-nums">{v.rescues}</span>
              </li>
            ))}
          </ol>
        </div>

        <div className="rounded-2xl border border-border bg-cream-light p-6">
          <div className="flex items-center gap-2">
            <GraduationCap className="h-5 w-5 text-ochre" />
            <h2 className="font-serif text-2xl text-primary">Food safety training</h2>
          </div>
          <ul className="mt-4 space-y-3">
            {[
              { t: "Cold-chain handling basics", done: true },
              { t: "FSSAI compliance for volunteers", done: true },
              { t: "Allergen identification", done: false },
              { t: "Last-mile hygiene protocols", done: false },
            ].map((m) => (
              <li key={m.t} className="flex items-center justify-between rounded-lg border border-border bg-background px-4 py-3">
                <span className={`text-sm ${m.done ? "text-muted-foreground line-through" : "text-primary"}`}>{m.t}</span>
                {m.done ? <CheckCircle2 className="h-4 w-4 text-cascade-fresh" /> : <button className="text-xs text-ochre-deep editorial-link">Start →</button>}
              </li>
            ))}
          </ul>
        </div>
      </section>
    </div>
  );
}
