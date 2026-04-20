import { useState, useMemo } from "react";
import { SELLERS } from "@/data/mock";
import { Search, MapPin, Award, Building2 } from "lucide-react";

const cities = ["All", "Bangalore"];
const verticals = ["All", "Restaurant", "Kirana", "Bakery", "Event", "Corporate"];

export default function GiversDirectory() {
  const [q, setQ] = useState("");
  const [vertical, setVertical] = useState("All");

  const filtered = useMemo(() => {
    return SELLERS.filter((s) =>
      (vertical === "All" || s.vertical === vertical) &&
      (q === "" || s.name.toLowerCase().includes(q.toLowerCase()) || s.area.toLowerCase().includes(q.toLowerCase()))
    );
  }, [q, vertical]);

  return (
    <div className="container py-10">
      <div>
        <p className="text-xs uppercase tracking-[0.25em] text-ochre">Directory</p>
        <h1 className="mt-2 font-serif text-4xl md:text-5xl text-primary">Food Givers</h1>
        <p className="mt-2 text-muted-foreground max-w-2xl">
          Every kitchen, kirana and bakery moving surplus through Annva. Verified, ranked by impact.
        </p>
      </div>

      {/* Search + filters */}
      <div className="mt-8 flex flex-wrap items-center gap-3">
        <label className="flex-1 min-w-[240px] flex items-center gap-2 rounded-full border border-border bg-cream-light px-4 py-2.5">
          <Search className="h-4 w-4 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search name or area…"
            className="flex-1 bg-transparent text-sm placeholder:text-muted-foreground focus:outline-none"
          />
        </label>
        <div className="flex flex-wrap gap-1.5">
          {verticals.map((v) => (
            <button
              key={v}
              onClick={() => setVertical(v)}
              className={`rounded-full px-3.5 py-1.5 text-xs transition-colors ${
                vertical === v ? "bg-primary text-primary-foreground" : "border border-border bg-cream-light text-muted-foreground hover:text-primary"
              }`}
            >
              {v}
            </button>
          ))}
        </div>
      </div>

      <p className="mt-4 text-xs text-muted-foreground">{filtered.length} givers</p>

      <div className="mt-4 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {filtered.map((s) => (
          <div key={s.name} className="rounded-2xl border border-border bg-cream-light p-6 hover:border-ochre transition-colors">
            <div className="flex items-start justify-between">
              <Building2 className="h-6 w-6 text-primary" />
              <span className="text-[10px] uppercase tracking-widest text-ochre">{s.vertical}</span>
            </div>
            <h3 className="mt-4 font-serif text-xl text-primary leading-tight">{s.name}</h3>
            <p className="text-xs text-muted-foreground mt-1 flex items-center gap-1">
              <MapPin className="h-3 w-3" /> {s.area}
            </p>
            <div className="mt-5 pt-5 border-t border-border grid grid-cols-2 gap-2">
              <div>
                <p className="text-[10px] uppercase tracking-widest text-muted-foreground">Lifetime kg</p>
                <p className="font-serif text-2xl text-primary tabular-nums">{s.rescued.toLocaleString("en-IN")}</p>
              </div>
              <div>
                <p className="text-[10px] uppercase tracking-widest text-muted-foreground">Impact rating</p>
                <p className="font-serif text-2xl text-ochre-deep flex items-center gap-1">
                  {s.score}<Award className="h-4 w-4 fill-ochre text-ochre" />
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
