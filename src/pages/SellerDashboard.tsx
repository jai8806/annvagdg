import { useState } from "react";
import { LISTINGS, formatINR } from "@/data/mock";
import { Camera, Upload, TrendingUp, FileText, Sparkles, IndianRupee, AlertTriangle } from "lucide-react";
import { RoleHeader } from "./ConsumerDashboard";

export default function SellerDashboard() {
  const [uploaded, setUploaded] = useState(false);
  const inventory = LISTINGS.slice(0, 6);
  const recovered = inventory.reduce((s, l) => s + l.currentPrice, 0);
  const wouldHaveLost = inventory.reduce((s, l) => s + l.originalPrice, 0);

  return (
    <div className="container py-10">
      <RoleHeader role="Seller" name="Ravi" subtitle="MTR — Lalbagh · Restaurant partner since 2024" />

      <div className="mt-8 grid gap-4 md:grid-cols-3">
        <div className="rounded-2xl border border-border bg-primary text-primary-foreground p-6">
          <p className="text-xs uppercase tracking-widest text-cream/70">Recovered today</p>
          <p className="mt-2 font-serif text-4xl">{formatINR(recovered)}</p>
          <p className="mt-1 text-xs text-cream/60">vs {formatINR(wouldHaveLost)} would-have-wasted</p>
          <div className="mt-4 h-1.5 rounded-full bg-cream/15 overflow-hidden">
            <div className="h-full bg-ochre" style={{ width: `${(recovered / wouldHaveLost) * 100}%` }} />
          </div>
        </div>

        <div className="rounded-2xl border border-border bg-cream-light p-6">
          <div className="flex items-center justify-between">
            <p className="text-xs uppercase tracking-widest text-muted-foreground">AlchemyScore</p>
            <Sparkles className="h-4 w-4 text-ochre" />
          </div>
          <p className="mt-2 font-serif text-4xl text-primary">782<span className="text-xl text-muted-foreground">/900</span></p>
          <p className="mt-1 text-xs text-muted-foreground">Eligible: ₹1.8L credit line via partner banks</p>
          <button className="mt-3 text-xs text-primary editorial-link">View AlchemyScore breakdown →</button>
        </div>

        <div className="rounded-2xl border border-border bg-cream-light p-6">
          <p className="text-xs uppercase tracking-widest text-muted-foreground">BRSR / ESG export</p>
          <p className="mt-2 text-sm text-muted-foreground">Q3 2026 sustainability report — 1,842 kg rescued, 4.6T CO₂e avoided.</p>
          <button className="mt-4 inline-flex items-center gap-2 text-xs rounded-full bg-secondary px-4 py-2 text-primary hover:bg-muted transition-colors">
            <FileText className="h-3.5 w-3.5" /> Download PDF
          </button>
        </div>
      </div>

      {/* List surplus */}
      <section className="mt-10 rounded-2xl border border-border bg-cream-light p-6">
        <div className="flex items-center justify-between flex-wrap gap-3">
          <div>
            <h2 className="font-serif text-2xl text-primary">List surplus food</h2>
            <p className="text-sm text-muted-foreground">Snap a photo. Our OCR fills the rest.</p>
          </div>
          <span className="inline-flex items-center gap-1.5 text-xs text-ochre"><Sparkles className="h-3.5 w-3.5" /> AI-assisted</span>
        </div>

        <div className="mt-5 grid gap-5 md:grid-cols-[280px_1fr]">
          <button
            onClick={() => setUploaded(true)}
            className="aspect-square rounded-2xl border-2 border-dashed border-border hover:border-ochre bg-background flex flex-col items-center justify-center transition-colors"
          >
            {uploaded ? (
              <>
                <div className="h-16 w-16 rounded-full bg-cascade-fresh/20 flex items-center justify-center">
                  <Camera className="h-7 w-7 text-cascade-fresh" />
                </div>
                <p className="mt-3 text-sm text-primary">tray-bisi-bele.jpg</p>
                <p className="text-xs text-muted-foreground">OCR complete · 0.6s</p>
              </>
            ) : (
              <>
                <Upload className="h-7 w-7 text-muted-foreground" />
                <p className="mt-3 text-sm text-primary">Tap to upload photo</p>
                <p className="text-xs text-muted-foreground">JPG, PNG · max 8 MB</p>
              </>
            )}
          </button>

          <div className="grid gap-3 grid-cols-2">
            <Field label="Item name" value={uploaded ? "Bisi bele bath" : ""} />
            <Field label="Vertical" value="Restaurant" />
            <Field label="Quantity (kg)" value={uploaded ? "8" : ""} />
            <Field label="Servings" value={uploaded ? "32" : ""} />
            <Field label="Original price" value={uploaded ? "₹2,400" : ""} />
            <Field label="Best by" value={uploaded ? "Today, 10:30 PM" : ""} />
            <div className="col-span-2">
              <button className="w-full rounded-full bg-primary text-primary-foreground py-3 text-sm hover:bg-indigo-deep transition-colors disabled:opacity-50" disabled={!uploaded}>
                Publish to cascade engine
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Live inventory */}
      <section className="mt-10">
        <div className="flex items-baseline justify-between">
          <h2 className="font-serif text-2xl text-primary">Live inventory</h2>
          <span className="text-xs text-muted-foreground">Auto-priced by cascade engine</span>
        </div>
        <div className="mt-4 rounded-2xl border border-border bg-cream-light overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-secondary text-muted-foreground">
              <tr className="text-left">
                <th className="px-4 py-3 font-normal text-xs uppercase tracking-widest">Item</th>
                <th className="px-4 py-3 font-normal text-xs uppercase tracking-widest">Stage</th>
                <th className="px-4 py-3 font-normal text-xs uppercase tracking-widest">Original</th>
                <th className="px-4 py-3 font-normal text-xs uppercase tracking-widest">Current</th>
                <th className="px-4 py-3 font-normal text-xs uppercase tracking-widest">Time</th>
              </tr>
            </thead>
            <tbody>
              {inventory.map((l) => (
                <tr key={l.id} className="border-t border-border">
                  <td className="px-4 py-3 text-primary">{l.name}</td>
                  <td className="px-4 py-3">
                    <span className={`inline-flex items-center gap-1.5 text-xs`}>
                      <span className={`h-2 w-2 rounded-full bg-${l.stage === "urgent" ? "cascade-urgent" : l.stage === "mid" ? "cascade-mid" : "cascade-fresh"}`} />
                      {l.stage === "urgent" ? "Final hour" : l.stage === "mid" ? "Cascade" : "Fresh"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-muted-foreground line-through">{formatINR(l.originalPrice)}</td>
                  <td className="px-4 py-3 text-primary">{formatINR(l.currentPrice)}</td>
                  <td className="px-4 py-3 text-muted-foreground">{l.hoursLeft}h</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {/* Predictive Waste Intelligence */}
      <section className="mt-10 rounded-2xl border border-ochre/40 bg-gradient-to-br from-ochre/10 to-transparent p-6">
        <div className="flex items-center gap-2">
          <TrendingUp className="h-5 w-5 text-ochre-deep" />
          <span className="text-xs uppercase tracking-widest text-ochre-deep">SaaS · Predictive Waste Intelligence</span>
        </div>
        <h3 className="mt-3 font-serif text-2xl text-primary">You're predicted to over-prep dosa batter by 18% this Saturday.</h3>
        <p className="mt-2 text-sm text-muted-foreground max-w-2xl">
          Based on weather, footfall, and historical surplus across 47 similar restaurants in your cluster. Reduce prep by 4.2 kg → save ~₹1,260 in input costs.
        </p>
        <div className="mt-4 flex gap-3 flex-wrap">
          <button className="inline-flex items-center gap-2 rounded-full bg-ochre text-ink px-5 py-2 text-sm font-medium hover:bg-ochre-deep hover:text-cream transition-colors">
            Activate PWI · ₹1,499/mo
          </button>
          <button className="text-sm text-primary editorial-link">See full forecast</button>
        </div>
      </section>
    </div>
  );
}

function Field({ label, value }: { label: string; value: string }) {
  return (
    <label className="block">
      <span className="text-[10px] uppercase tracking-widest text-muted-foreground">{label}</span>
      <input
        readOnly
        value={value}
        placeholder="—"
        className="mt-1 w-full rounded-md border border-border bg-background px-3 py-2 text-sm text-primary focus:outline-none"
      />
    </label>
  );
}
