import { useMemo, useState } from "react";
import { MapContainer, TileLayer, CircleMarker, Popup, useMap } from "react-leaflet";
import L from "leaflet";
import { LISTINGS, FoodListing, formatINR, stageLabel } from "@/data/mock";
import { Filter, X, Clock, MapPin, Package } from "lucide-react";
import { cn } from "@/lib/utils";

const STAGE_HSL = {
  fresh: "hsl(142 45% 38%)",
  mid: "hsl(36 78% 57%)",
  urgent: "hsl(8 72% 50%)",
};

function FlyTo({ pos }: { pos: [number, number] | null }) {
  const map = useMap();
  if (pos) map.flyTo(pos, 14, { duration: 0.8 });
  return null;
}

export default function HeatmapPage() {
  const [selected, setSelected] = useState<FoodListing | null>(null);
  const [vertical, setVertical] = useState<string>("All");
  const [diet, setDiet] = useState<string>("All");
  const [stage, setStage] = useState<string>("All");

  const filtered = useMemo(() => {
    return LISTINGS.filter((l) =>
      (vertical === "All" || l.vertical === vertical) &&
      (diet === "All" || l.diet.includes(diet as any)) &&
      (stage === "All" || l.stage === stage)
    );
  }, [vertical, diet, stage]);

  const stageCounts = {
    urgent: LISTINGS.filter((l) => l.stage === "urgent").length,
    mid: LISTINGS.filter((l) => l.stage === "mid").length,
    fresh: LISTINGS.filter((l) => l.stage === "fresh").length,
  };

  return (
    <div className="container py-10">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.25em] text-ochre">Bengaluru · Live</p>
          <h1 className="mt-2 font-serif text-4xl md:text-5xl text-primary">Urgency Heatmap</h1>
          <p className="mt-2 text-muted-foreground max-w-xl">
            Every dot is surplus food, priced against the clock. Tap a pin to reserve or volunteer for pickup.
          </p>
        </div>
        <div className="flex items-center gap-4 text-sm">
          <Legend dot="cascade-urgent" label={`Final hour (${stageCounts.urgent})`} pulse />
          <Legend dot="cascade-mid" label={`Cascade (${stageCounts.mid})`} />
          <Legend dot="cascade-fresh" label={`Fresh (${stageCounts.fresh})`} />
        </div>
      </div>

      {/* Filters */}
      <div className="mt-6 flex flex-wrap items-center gap-2">
        <Filter className="h-4 w-4 text-muted-foreground mr-1" />
        <FilterSelect label="Vertical" value={vertical} onChange={setVertical} options={["All", "Restaurant", "Kirana", "Bakery", "Event", "Corporate"]} />
        <FilterSelect label="Diet" value={diet} onChange={setDiet} options={["All", "veg", "jain", "halal", "non-veg"]} />
        <FilterSelect label="Stage" value={stage} onChange={setStage} options={["All", "fresh", "mid", "urgent"]} />
        <span className="ml-auto text-xs text-muted-foreground">{filtered.length} active listings</span>
      </div>

      <div className="mt-6 grid gap-4 lg:grid-cols-[1fr_360px]">
        {/* Map */}
        <div className="rounded-2xl overflow-hidden border border-border h-[68vh] min-h-[520px]">
          <MapContainer center={[12.9551, 77.6076]} zoom={12} className="h-full w-full" scrollWheelZoom>
            <TileLayer
              attribution='&copy; OpenStreetMap'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <FlyTo pos={selected ? [selected.lat, selected.lng] : null} />
            {filtered.map((l) => (
              <CircleMarker
                key={l.id}
                center={[l.lat, l.lng]}
                radius={l.stage === "urgent" ? 14 : l.stage === "mid" ? 11 : 9}
                pathOptions={{
                  color: STAGE_HSL[l.stage],
                  fillColor: STAGE_HSL[l.stage],
                  fillOpacity: 0.6,
                  weight: 2,
                }}
                eventHandlers={{ click: () => setSelected(l) }}
              >
                <Popup>
                  <div className="font-sans">
                    <p className="font-serif text-base text-primary">{l.name}</p>
                    <p className="text-xs text-muted-foreground">{l.seller}</p>
                  </div>
                </Popup>
              </CircleMarker>
            ))}
          </MapContainer>
        </div>

        {/* Side list / detail */}
        <aside className="rounded-2xl border border-border bg-cream-light overflow-hidden flex flex-col h-[68vh] min-h-[520px]">
          {selected ? (
            <DetailPanel listing={selected} onClose={() => setSelected(null)} />
          ) : (
            <div className="overflow-y-auto p-2">
              <p className="px-3 pt-2 pb-1 text-xs uppercase tracking-widest text-muted-foreground">Tap a pin or pick a listing</p>
              {filtered.sort((a, b) => a.hoursLeft - b.hoursLeft).map((l) => (
                <button
                  key={l.id}
                  onClick={() => setSelected(l)}
                  className="w-full text-left px-3 py-3 rounded-xl hover:bg-secondary transition-colors flex items-start gap-3"
                >
                  <span
                    className={cn("mt-1.5 h-2.5 w-2.5 rounded-full shrink-0", l.stage === "urgent" && "urgency-pulse")}
                    style={{ background: STAGE_HSL[l.stage] }}
                  />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-primary truncate">{l.name}</p>
                    <p className="text-xs text-muted-foreground truncate">{l.seller}</p>
                    <div className="flex items-center gap-3 mt-1 text-[11px] text-muted-foreground">
                      <span className="flex items-center gap-1"><Clock className="h-3 w-3" />{l.hoursLeft}h left</span>
                      <span>{formatINR(l.currentPrice)}</span>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </aside>
      </div>
    </div>
  );
}

function Legend({ dot, label, pulse }: { dot: string; label: string; pulse?: boolean }) {
  return (
    <span className="inline-flex items-center gap-2 text-xs text-muted-foreground">
      <span className={cn(`h-2.5 w-2.5 rounded-full bg-${dot}`, pulse && "urgency-pulse")} />
      {label}
    </span>
  );
}

function FilterSelect({ label, value, onChange, options }: { label: string; value: string; onChange: (v: string) => void; options: string[] }) {
  return (
    <label className="inline-flex items-center gap-1.5 rounded-full border border-border bg-cream-light px-3 py-1.5 text-xs">
      <span className="text-muted-foreground">{label}:</span>
      <select value={value} onChange={(e) => onChange(e.target.value)} className="bg-transparent text-primary capitalize focus:outline-none">
        {options.map((o) => (
          <option key={o} value={o} className="capitalize">{o}</option>
        ))}
      </select>
    </label>
  );
}

function DetailPanel({ listing, onClose }: { listing: FoodListing; onClose: () => void }) {
  const discount = listing.originalPrice > 0 ? Math.round((1 - listing.currentPrice / listing.originalPrice) * 100) : 100;
  return (
    <div className="flex flex-col h-full">
      <div className="p-5 border-b border-border flex items-start justify-between">
        <div>
          <p className="text-xs uppercase tracking-widest text-ochre">{stageLabel(listing.stage)}</p>
          <h3 className="mt-1 font-serif text-2xl text-primary">{listing.name}</h3>
          <p className="text-sm text-muted-foreground">{listing.seller}</p>
        </div>
        <button onClick={onClose} className="p-1 hover:bg-secondary rounded-md"><X className="h-4 w-4" /></button>
      </div>

      <div className="p-5 flex-1 overflow-y-auto space-y-5">
        <div className="flex items-baseline gap-3">
          <span className="font-serif text-4xl text-primary">{formatINR(listing.currentPrice)}</span>
          {listing.originalPrice > 0 && (
            <>
              <span className="text-sm text-muted-foreground line-through">{formatINR(listing.originalPrice)}</span>
              <span className="text-xs px-2 py-0.5 rounded-full bg-ochre/20 text-ochre-deep">−{discount}%</span>
            </>
          )}
        </div>

        <div className="grid grid-cols-2 gap-3 text-sm">
          <Stat icon={Clock} label="Time left" value={`${listing.hoursLeft}h`} />
          <Stat icon={Package} label="Quantity" value={`${listing.qtyKg} kg`} />
          <Stat icon={Package} label="Servings" value={`${listing.servings}`} />
          <Stat icon={MapPin} label="Pickup" value={listing.address} />
        </div>

        <div>
          <p className="text-xs uppercase tracking-widest text-muted-foreground mb-2">Diet</p>
          <div className="flex flex-wrap gap-1.5">
            {listing.diet.map((d) => (
              <span key={d} className="px-2.5 py-1 rounded-full bg-secondary text-xs text-primary capitalize">{d}</span>
            ))}
          </div>
        </div>
      </div>

      <div className="p-5 border-t border-border space-y-2">
        <button className="w-full rounded-full bg-primary text-primary-foreground py-3 text-sm hover:bg-indigo-deep transition-colors">
          {listing.currentPrice === 0 ? "Volunteer for pickup" : "Reserve for ₹" + listing.currentPrice}
        </button>
        <button className="w-full rounded-full border border-border bg-cream-light py-3 text-sm hover:border-ochre transition-colors">
          Share with NGO partner
        </button>
      </div>
    </div>
  );
}

function Stat({ icon: Icon, label, value }: { icon: any; label: string; value: string }) {
  return (
    <div className="rounded-lg border border-border bg-background p-3">
      <div className="flex items-center gap-1.5 text-[10px] uppercase tracking-widest text-muted-foreground">
        <Icon className="h-3 w-3" /> {label}
      </div>
      <p className="mt-1 text-primary text-sm">{value}</p>
    </div>
  );
}
