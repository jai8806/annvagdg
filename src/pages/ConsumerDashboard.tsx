import { LISTINGS, formatINR } from "@/data/mock";
import { Wallet, Leaf, Heart, IndianRupee, Clock, Heart as Save, Package } from "lucide-react";

export default function ConsumerDashboard() {
  const feed = LISTINGS.filter((l) => l.currentPrice > 0).sort((a, b) => a.hoursLeft - b.hoursLeft);
  const stats = [
    { icon: Heart, label: "Meals saved", value: "84" },
    { icon: Leaf, label: "Kg CO₂ avoided", value: "126" },
    { icon: IndianRupee, label: "Money saved", value: "₹4,820" },
    { icon: Package, label: "Kg rescued", value: "53" },
  ];

  return (
    <div className="container py-10">
      <RoleHeader role="Consumer" name="Aanya" subtitle="Indiranagar, Bengaluru" />

      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((s) => (
          <div key={s.label} className="rounded-2xl border border-border bg-cream-light p-5">
            <s.icon className="h-5 w-5 text-ochre" />
            <p className="mt-3 text-xs uppercase tracking-widest text-muted-foreground">{s.label}</p>
            <p className="mt-1 font-serif text-3xl text-primary">{s.value}</p>
          </div>
        ))}
      </div>

      <div className="mt-10 grid gap-8 lg:grid-cols-[1fr_320px]">
        <section>
          <div className="flex items-baseline justify-between">
            <h2 className="font-serif text-2xl text-primary">Discover near you</h2>
            <span className="text-xs text-muted-foreground">{feed.length} listings within 5 km</span>
          </div>

          <div className="mt-4 grid gap-4 sm:grid-cols-2">
            {feed.map((l) => {
              const discount = Math.round((1 - l.currentPrice / l.originalPrice) * 100);
              return (
                <div key={l.id} className="rounded-2xl border border-border bg-cream-light overflow-hidden hover:-translate-y-1 hover:border-ochre transition-all">
                  <div className="aspect-[4/2] bg-gradient-to-br from-secondary to-muted relative">
                    <span className="absolute top-3 left-3 text-[10px] uppercase tracking-widest px-2 py-1 rounded-full bg-background/80 text-primary">{l.vertical}</span>
                    <span className={`absolute top-3 right-3 text-[10px] uppercase tracking-widest px-2 py-1 rounded-full text-primary-foreground bg-${l.stage === "urgent" ? "cascade-urgent" : l.stage === "mid" ? "cascade-mid" : "cascade-fresh"}`}>
                      {l.hoursLeft}h
                    </span>
                  </div>
                  <div className="p-4">
                    <p className="font-serif text-lg text-primary leading-tight">{l.name}</p>
                    <p className="text-xs text-muted-foreground mt-0.5">{l.seller}</p>
                    <div className="mt-3 flex items-baseline justify-between">
                      <div className="flex items-baseline gap-2">
                        <span className="text-primary font-medium">{formatINR(l.currentPrice)}</span>
                        <span className="text-xs text-muted-foreground line-through">{formatINR(l.originalPrice)}</span>
                      </div>
                      <span className="text-xs px-2 py-0.5 rounded-full bg-ochre/20 text-ochre-deep">−{discount}%</span>
                    </div>
                    <button className="mt-3 w-full rounded-full bg-primary text-primary-foreground py-2 text-xs hover:bg-indigo-deep transition-colors">Reserve</button>
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        <aside className="space-y-4">
          <div className="rounded-2xl border border-border bg-primary text-primary-foreground p-5">
            <div className="flex items-center gap-2">
              <Wallet className="h-5 w-5 text-ochre" />
              <p className="text-xs uppercase tracking-widest text-cream/70">Annva Wallet</p>
            </div>
            <p className="mt-3 font-serif text-4xl">₹1,240</p>
            <p className="mt-1 text-xs text-cream/60">Cashback from rescues · withdrawable</p>
            <button className="mt-4 w-full rounded-full bg-cream/10 hover:bg-cream/20 transition-colors py-2 text-xs">Top up</button>
          </div>

          <div className="rounded-2xl border border-border bg-cream-light p-5">
            <p className="text-xs uppercase tracking-widest text-muted-foreground">Active orders (2)</p>
            <ul className="mt-3 space-y-3 text-sm">
              <li>
                <p className="text-primary">Croissants · BBK Bakery</p>
                <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5"><Clock className="h-3 w-3" /> Pickup by 9:30 PM</p>
              </li>
              <li>
                <p className="text-primary">Veg thali · Nandhini</p>
                <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5"><Clock className="h-3 w-3" /> Pickup by 10:15 PM</p>
              </li>
            </ul>
          </div>

          <div className="rounded-2xl border border-border bg-cream-light p-5">
            <p className="text-xs uppercase tracking-widest text-muted-foreground">Saved sellers</p>
            <ul className="mt-3 space-y-2 text-sm text-primary">
              <li className="flex justify-between"><span>MTR — Lalbagh</span><Save className="h-3.5 w-3.5 fill-ochre text-ochre" /></li>
              <li className="flex justify-between"><span>Third Wave Coffee</span><Save className="h-3.5 w-3.5 fill-ochre text-ochre" /></li>
              <li className="flex justify-between"><span>Daily Bread</span><Save className="h-3.5 w-3.5 fill-ochre text-ochre" /></li>
            </ul>
          </div>
        </aside>
      </div>
    </div>
  );
}

export function RoleHeader({ role, name, subtitle }: { role: string; name: string; subtitle: string }) {
  return (
    <div className="flex items-end justify-between">
      <div>
        <p className="text-xs uppercase tracking-[0.25em] text-ochre">{role} · Demo</p>
        <h1 className="mt-2 font-serif text-4xl md:text-5xl text-primary">Hello, {name}</h1>
        <p className="mt-1 text-muted-foreground">{subtitle}</p>
      </div>
      <div className="hidden md:block h-14 w-14 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-serif text-xl">
        <span className="m-auto">{name.charAt(0)}</span>
      </div>
    </div>
  );
}
