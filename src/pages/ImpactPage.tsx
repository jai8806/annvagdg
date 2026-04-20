import { useState } from "react";
import { LIVE_IMPACT } from "@/data/mock";
import { CheckCircle2, Download, Search, Leaf, Heart, Users, Building2 } from "lucide-react";

const yearMetrics = [
  { y: "Year 1", kg: 487_312, meals: 1_948_240, sellers: 1240, volunteers: 3890, co2: 1_236_478 },
  { y: "Year 2 (proj)", kg: 1_840_000, meals: 7_360_000, sellers: 4800, volunteers: 14200, co2: 4_660_000 },
  { y: "Year 3 (proj)", kg: 5_120_000, meals: 20_480_000, sellers: 12500, volunteers: 38000, co2: 12_980_000 },
];

const sdgs = [
  { n: 2, t: "Zero Hunger", color: "bg-ochre" },
  { n: 12, t: "Responsible Consumption", color: "bg-cascade-fresh" },
  { n: 13, t: "Climate Action", color: "bg-primary" },
  { n: 1, t: "No Poverty", color: "bg-cascade-urgent" },
  { n: 17, t: "Partnerships", color: "bg-ochre-deep" },
];

const auditFeed = [
  { id: "ANV-7842", t: "8.1 kg rescued from MTR Lalbagh → Akshaya Patra", time: "2 min ago" },
  { id: "ANV-7841", t: "12.4 kg rescued from Reliance Fresh → Robin Hood Army", time: "6 min ago" },
  { id: "ANV-7840", t: "Wedding banquet certified Zero-Waste · Taj West End", time: "12 min ago" },
  { id: "ANV-7839", t: "3.6 kg rescued from BBK Bakery → Feeding India", time: "18 min ago" },
  { id: "ANV-7838", t: "Volunteer Ananya Rao earned Chapter Lead status", time: "24 min ago" },
];

export default function ImpactPage() {
  const [verifyId, setVerifyId] = useState("");
  const [verifyResult, setVerifyResult] = useState<null | "valid" | "invalid">(null);

  const handleVerify = () => {
    setVerifyResult(verifyId.trim().startsWith("ANV-") ? "valid" : "invalid");
  };

  return (
    <div className="container py-10">
      <div>
        <p className="text-xs uppercase tracking-[0.25em] text-ochre">Verified Impact</p>
        <h1 className="mt-2 font-serif text-4xl md:text-6xl text-primary leading-tight">
          Every gram, every meal,<br />on the public ledger.
        </h1>
        <p className="mt-4 text-muted-foreground max-w-2xl text-lg">
          Annva publishes live, transaction-level rescue data. Auditable by NGOs, regulators, and partners — no black box.
        </p>
      </div>

      {/* Year metrics */}
      <section className="mt-12 rounded-2xl border border-border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-primary text-primary-foreground">
            <tr className="text-left">
              <th className="px-5 py-4 font-normal text-xs uppercase tracking-widest">Period</th>
              <th className="px-5 py-4 font-normal text-xs uppercase tracking-widest">Kg rescued</th>
              <th className="px-5 py-4 font-normal text-xs uppercase tracking-widest">Meals delivered</th>
              <th className="px-5 py-4 font-normal text-xs uppercase tracking-widest">Sellers</th>
              <th className="px-5 py-4 font-normal text-xs uppercase tracking-widest">Volunteers</th>
              <th className="px-5 py-4 font-normal text-xs uppercase tracking-widest">CO₂ avoided (kg)</th>
            </tr>
          </thead>
          <tbody className="bg-cream-light">
            {yearMetrics.map((y) => (
              <tr key={y.y} className="border-t border-border">
                <td className="px-5 py-4 font-serif text-lg text-primary">{y.y}</td>
                <td className="px-5 py-4 text-primary tabular-nums">{y.kg.toLocaleString("en-IN")}</td>
                <td className="px-5 py-4 text-primary tabular-nums">{y.meals.toLocaleString("en-IN")}</td>
                <td className="px-5 py-4 text-primary tabular-nums">{y.sellers.toLocaleString("en-IN")}</td>
                <td className="px-5 py-4 text-primary tabular-nums">{y.volunteers.toLocaleString("en-IN")}</td>
                <td className="px-5 py-4 text-primary tabular-nums">{y.co2.toLocaleString("en-IN")}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      {/* SDGs */}
      <section className="mt-14">
        <h2 className="font-serif text-3xl text-primary">UN SDG alignment</h2>
        <div className="mt-5 grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
          {sdgs.map((s) => (
            <div key={s.n} className="rounded-2xl border border-border bg-cream-light overflow-hidden">
              <div className={`${s.color} h-20 flex items-center justify-center`}>
                <span className="font-serif text-5xl text-cream">{s.n}</span>
              </div>
              <div className="p-4">
                <p className="font-serif text-lg text-primary leading-tight">{s.t}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Live audit + verification */}
      <section className="mt-14 grid gap-6 lg:grid-cols-2">
        <div className="rounded-2xl border border-border bg-cream-light p-6">
          <div className="flex items-center justify-between">
            <h2 className="font-serif text-2xl text-primary">Live audit feed</h2>
            <span className="inline-flex items-center gap-1.5 text-xs text-cascade-fresh">
              <span className="h-1.5 w-1.5 rounded-full bg-cascade-fresh animate-pulse" /> Streaming
            </span>
          </div>
          <ul className="mt-4 divide-y divide-border">
            {auditFeed.map((a) => (
              <li key={a.id} className="py-3">
                <div className="flex items-center justify-between">
                  <span className="font-mono text-[11px] text-ochre-deep">{a.id}</span>
                  <span className="text-xs text-muted-foreground">{a.time}</span>
                </div>
                <p className="mt-1 text-sm text-primary">{a.t}</p>
              </li>
            ))}
          </ul>
        </div>

        <div className="space-y-4">
          <div className="rounded-2xl border border-border bg-cream-light p-6">
            <h2 className="font-serif text-2xl text-primary">Verify a certificate</h2>
            <p className="text-sm text-muted-foreground mt-1">Paste a certificate ID (try <span className="font-mono text-ochre-deep">ANV-7842</span>) to confirm authenticity.</p>
            <div className="mt-4 flex gap-2">
              <input
                value={verifyId}
                onChange={(e) => setVerifyId(e.target.value)}
                placeholder="ANV-XXXX"
                className="flex-1 rounded-full border border-border bg-background px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
              />
              <button onClick={handleVerify} className="rounded-full bg-primary text-primary-foreground px-5 text-sm hover:bg-indigo-deep transition-colors">
                <Search className="h-4 w-4" />
              </button>
            </div>
            {verifyResult === "valid" && (
              <div className="mt-4 rounded-lg border border-cascade-fresh/40 bg-cascade-fresh/10 p-4 animate-fade-in">
                <p className="inline-flex items-center gap-2 text-sm text-cascade-fresh">
                  <CheckCircle2 className="h-4 w-4" /> Certificate <span className="font-mono">{verifyId}</span> is valid.
                </p>
                <p className="mt-1 text-xs text-muted-foreground">Issued to volunteer · 8.1 kg · MTR Lalbagh → Akshaya Patra · Apr 18, 2026</p>
              </div>
            )}
            {verifyResult === "invalid" && (
              <p className="mt-4 text-sm text-cascade-urgent">No certificate found for this ID.</p>
            )}
          </div>

          <div className="rounded-2xl border border-border bg-primary text-primary-foreground p-6">
            <h2 className="font-serif text-2xl">Downloads</h2>
            <p className="text-sm text-cream/70 mt-1">Independently verified mockup reports.</p>
            <div className="mt-4 grid sm:grid-cols-2 gap-2">
              {["BRSR Q3 2026", "Carbon Credits 2026", "Annual Impact Report", "GRI alignment"].map((d) => (
                <button key={d} className="flex items-center justify-between rounded-lg bg-cream/10 hover:bg-cream/20 transition-colors px-4 py-3 text-sm text-left">
                  {d} <Download className="h-3.5 w-3.5" />
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
