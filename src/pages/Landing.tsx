import { useEffect, useState } from "react";
import { ArrowRight, Clock, Leaf, MapPin, Sparkles, TrendingDown, Users, Award, Building2, Cookie, ShoppingBasket, PartyPopper, Briefcase } from "lucide-react";
import { Link } from "react-router-dom";
import { LIVE_IMPACT, formatINR } from "@/data/mock";

function useCountdown(initialMinutes: number) {
  const [seconds, setSeconds] = useState(initialMinutes * 60);
  useEffect(() => {
    const t = setInterval(() => setSeconds((s) => (s > 0 ? s - 1 : initialMinutes * 60)), 1000);
    return () => clearInterval(t);
  }, [initialMinutes]);
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return `${h}h ${m.toString().padStart(2, "0")}m ${s.toString().padStart(2, "0")}s`;
}

function Counter({ to, suffix = "", duration = 1800 }: { to: number; suffix?: string; duration?: number }) {
  const [n, setN] = useState(0);
  useEffect(() => {
    const start = performance.now();
    let raf = 0;
    const tick = (now: number) => {
      const p = Math.min(1, (now - start) / duration);
      setN(Math.floor(to * (0.5 - Math.cos(p * Math.PI) / 2)));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [to, duration]);
  return <span>{n.toLocaleString("en-IN")}{suffix}</span>;
}

const verticals = [
  { icon: Building2, name: "Restaurants", line: "End-of-day surplus, catered events, banquet leftovers" },
  { icon: ShoppingBasket, name: "Kiranas", line: "Near-expiry produce, dairy, packaged goods" },
  { icon: Cookie, name: "Bakeries", line: "Fresh-bake commitment, daily rotation surplus" },
  { icon: PartyPopper, name: "Events", line: "Weddings, parties, conferences — Zero-Waste Certificate" },
  { icon: Briefcase, name: "Corporate", line: "Office cafés, canteen surplus, BRSR-aligned reporting" },
];

const tiers = [
  { name: "Bronze", req: "5+ rescues", perks: "Verified ID + LinkedIn badge" },
  { name: "Silver", req: "50+ rescues", perks: "NCC/NSS credit hours" },
  { name: "Gold", req: "125+ rescues", perks: "NAAC-eligible certificate" },
  { name: "Chapter Lead", req: "250+ rescues", perks: "City team + stipend" },
];

export default function Landing() {
  const countdown = useCountdown(107);
  const [tickerN, setTickerN] = useState(LIVE_IMPACT.kgRescued);
  useEffect(() => {
    const t = setInterval(() => setTickerN((n) => n + Math.floor(Math.random() * 4) + 1), 2200);
    return () => clearInterval(t);
  }, []);

  return (
    <div className="overflow-hidden">
      {/* HERO */}
      <section className="relative">
        <span className="devanagari-watermark absolute -left-4 top-10 text-[18rem] leading-none select-none hidden md:block">अन्न</span>
        <div className="container relative pt-16 pb-20 md:pt-24 md:pb-32">
          <div className="max-w-3xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-ochre/40 bg-ochre/10 px-4 py-1.5 text-xs uppercase tracking-[0.2em] text-ochre-deep ochre-pulse">
              <Sparkles className="h-3 w-3" /> India · Live in 6 cities
            </div>
            <h1 className="mt-6 font-serif text-6xl md:text-8xl text-primary leading-[0.95]">
              Food <em className="text-ochre-deep">that</em> moves.
            </h1>
            <p className="mt-6 text-lg md:text-xl text-muted-foreground max-w-xl leading-relaxed">
              78 million tonnes wasted. 194 million undernourished. We built the cascade engine that closes the gap — in real time, across 5 verticals.
            </p>

            <div className="mt-8 flex flex-wrap items-center gap-3">
              <Link to="/map" className="inline-flex items-center gap-2 rounded-full bg-primary px-6 py-3 text-sm font-medium text-primary-foreground hover:bg-indigo-deep transition-colors">
                Open live heatmap <ArrowRight className="h-4 w-4" />
              </Link>
              <Link to="/seller" className="inline-flex items-center gap-2 rounded-full border border-border bg-cream-light px-6 py-3 text-sm hover:border-ochre transition-colors">
                I have surplus
              </Link>
            </div>

            <div className="mt-10 inline-flex items-center gap-3 rounded-2xl border border-border bg-cream-light px-5 py-4 shadow-sm">
              <div className="h-2.5 w-2.5 rounded-full bg-cascade-urgent urgency-pulse" />
              <div>
                <p className="text-[10px] uppercase tracking-widest text-muted-foreground">Free pickup ends in</p>
                <p className="font-mono text-lg text-primary tabular-nums">{countdown}</p>
              </div>
              <div className="ml-4 hidden sm:block border-l border-border pl-4">
                <p className="text-xs text-muted-foreground">MTR — Lalbagh</p>
                <p className="text-sm text-primary">8 kg bisi bele bath · 32 servings</p>
              </div>
            </div>
          </div>
        </div>
        <div className="grain-divider" />
      </section>

      {/* THE PARADOX */}
      <section className="container py-20 md:py-28">
        <p className="text-xs uppercase tracking-[0.25em] text-ochre">The Paradox</p>
        <h2 className="mt-3 font-serif text-4xl md:text-6xl text-primary max-w-3xl leading-tight">
          Two truths India lives with, every single day.
        </h2>

        <div className="mt-14 grid gap-px bg-border md:grid-cols-2 rounded-2xl overflow-hidden border border-border">
          <div className="bg-cream-light p-8 md:p-12">
            <TrendingDown className="h-8 w-8 text-cascade-urgent" />
            <p className="mt-6 font-serif text-7xl md:text-8xl text-primary tabular-nums">
              <Counter to={78} suffix="M" />
            </p>
            <p className="mt-1 text-sm uppercase tracking-widest text-muted-foreground">tonnes of food wasted, annually</p>
            <p className="mt-4 text-muted-foreground max-w-md">Enough to feed every undernourished Indian, twice over. Most of it spoils within hours of being marked unsellable.</p>
          </div>
          <div className="bg-cream-light p-8 md:p-12">
            <Users className="h-8 w-8 text-ochre-deep" />
            <p className="mt-6 font-serif text-7xl md:text-8xl text-primary tabular-nums">
              <Counter to={194} suffix="M" />
            </p>
            <p className="mt-1 text-sm uppercase tracking-widest text-muted-foreground">Indians go to bed undernourished</p>
            <p className="mt-4 text-muted-foreground max-w-md">The world's largest hungry population — concentrated in the same cities where surplus is highest.</p>
          </div>
        </div>
      </section>

      {/* CASCADE ENGINE */}
      <section className="bg-primary text-primary-foreground py-20 md:py-28 relative overflow-hidden">
        <span className="devanagari-watermark absolute right-0 -bottom-20 text-[22rem] leading-none text-cream/[0.03] hidden md:block">कास्केड</span>
        <div className="container relative">
          <p className="text-xs uppercase tracking-[0.25em] text-ochre">The Engine</p>
          <h2 className="mt-3 font-serif text-4xl md:text-6xl max-w-3xl leading-tight">
            The Urgency Cascade — pricing food against the clock.
          </h2>
          <p className="mt-5 max-w-2xl text-cream/70 text-lg">
            One AI engine, three stages. As food approaches expiry, price drops, demand widens, and beyond a final threshold — it goes free, dispatched to NGOs by our volunteer network.
          </p>

          <div className="mt-16 grid gap-6 md:grid-cols-3">
            {[
              { stage: "01", t: "12h → 6h", title: "Fresh", price: "−20%", color: "cascade-fresh", desc: "Listed to nearby consumers via the Annva app. Discounted to clear inventory." },
              { stage: "02", t: "6h → 2h", title: "Cascade", price: "−50%", color: "cascade-mid", desc: "Pricing drops sharply. Pinged to bulk buyers, kiranas, hostels, and corporate cafés." },
              { stage: "03", t: "<2h", title: "Final hour", price: "Free", color: "cascade-urgent", desc: "Auto-routed to verified NGOs. Volunteers dispatched. Every gram traceable." },
            ].map((s) => (
              <div key={s.stage} className="group rounded-2xl border border-cream/15 bg-cream/[0.04] p-7 hover:bg-cream/[0.08] transition-colors">
                <div className="flex items-baseline justify-between">
                  <span className={`inline-block h-2 w-2 rounded-full bg-${s.color}`} />
                  <span className="font-mono text-xs text-cream/50">{s.stage}</span>
                </div>
                <p className="mt-5 text-xs uppercase tracking-widest text-cream/60">{s.t}</p>
                <h3 className="mt-2 font-serif text-4xl">{s.title}</h3>
                <p className={`mt-1 text-2xl font-mono text-${s.color === "cascade-fresh" ? "cascade-fresh" : s.color === "cascade-mid" ? "cascade-mid" : "cascade-urgent"}`}>{s.price}</p>
                <p className="mt-5 text-sm text-cream/70 leading-relaxed">{s.desc}</p>
              </div>
            ))}
          </div>

          <Link to="/map" className="mt-12 inline-flex items-center gap-2 text-ochre editorial-link">
            See the cascade live on the heatmap <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </section>

      {/* LIVE TICKER */}
      <section className="border-y border-border bg-cream-light">
        <div className="container py-10 grid grid-cols-2 md:grid-cols-4 gap-6">
          {[
            { label: "Kg rescued (live)", v: tickerN },
            { label: "Meals delivered", v: LIVE_IMPACT.mealsDelivered },
            { label: "Kg CO₂ avoided", v: LIVE_IMPACT.co2Saved },
            { label: "Volunteers active", v: LIVE_IMPACT.volunteersActive },
          ].map((s) => (
            <div key={s.label}>
              <p className="text-xs uppercase tracking-widest text-muted-foreground">{s.label}</p>
              <p className="mt-1 font-serif text-3xl md:text-4xl text-primary tabular-nums animate-ticker">{s.v.toLocaleString("en-IN")}</p>
            </div>
          ))}
        </div>
      </section>

      {/* VERTICALS */}
      <section className="container py-20 md:py-28">
        <p className="text-xs uppercase tracking-[0.25em] text-ochre">Five Verticals</p>
        <h2 className="mt-3 font-serif text-4xl md:text-6xl text-primary max-w-3xl leading-tight">
          Every kitchen in India, on a single rail.
        </h2>
        <div className="mt-12 grid gap-5 md:grid-cols-2 lg:grid-cols-3">
          {verticals.map((v, i) => (
            <div key={v.name} className="group rounded-2xl border border-border bg-cream-light p-7 hover:border-ochre hover:-translate-y-1 transition-all">
              <div className="flex items-center justify-between">
                <v.icon className="h-7 w-7 text-primary" />
                <span className="font-mono text-xs text-muted-foreground">0{i + 1}</span>
              </div>
              <h3 className="mt-6 font-serif text-2xl text-primary">{v.name}</h3>
              <p className="mt-2 text-sm text-muted-foreground leading-relaxed">{v.line}</p>
            </div>
          ))}
          <Link to="/givers" className="rounded-2xl border-2 border-dashed border-border p-7 flex flex-col items-start justify-center hover:border-ochre transition-colors group">
            <ArrowRight className="h-7 w-7 text-ochre group-hover:translate-x-1 transition-transform" />
            <h3 className="mt-6 font-serif text-2xl text-primary">Browse all givers</h3>
            <p className="mt-2 text-sm text-muted-foreground">1,240 verified sellers across 6 cities.</p>
          </Link>
        </div>
      </section>

      {/* CERTIFICATION */}
      <section className="container py-20 md:py-28">
        <div className="grid gap-12 md:grid-cols-2 items-start">
          <div>
            <p className="text-xs uppercase tracking-[0.25em] text-ochre">Volunteers</p>
            <h2 className="mt-3 font-serif text-4xl md:text-5xl text-primary leading-tight">
              Every rescue earns a verified credential — for life.
            </h2>
            <p className="mt-5 text-muted-foreground text-lg">
              Geotagged, timestamped, NGO-confirmed. Recognized by NCC, NSS, NYKS and accepted as NAAC volunteer hours by 200+ universities.
            </p>
            <Link to="/volunteer" className="mt-6 inline-flex items-center gap-2 text-primary editorial-link">
              Volunteer dashboard <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
          <div className="space-y-3">
            {tiers.map((t) => (
              <div key={t.name} className="flex items-center gap-5 rounded-xl border border-border bg-cream-light p-5">
                <Award className="h-8 w-8 text-ochre shrink-0" />
                <div className="flex-1">
                  <div className="flex items-baseline justify-between">
                    <h4 className="font-serif text-2xl text-primary">{t.name}</h4>
                    <span className="text-xs uppercase tracking-widest text-muted-foreground">{t.req}</span>
                  </div>
                  <p className="mt-1 text-sm text-muted-foreground">{t.perks}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* INVESTOR STRIP */}
      <section className="bg-primary text-primary-foreground">
        <div className="container py-14 md:py-20 grid gap-8 md:grid-cols-3 items-center">
          <div className="md:col-span-2">
            <p className="text-xs uppercase tracking-[0.25em] text-ochre">For Investors</p>
            <h3 className="mt-2 font-serif text-3xl md:text-4xl">
              ₹1.52 lakh crore market. ₹1.5–2 Cr seed. 36-month path to profitability.
            </h3>
            <p className="mt-3 text-cream/70 max-w-2xl">
              Five revenue lines: SaaS for sellers, transaction fees, BRSR/ESG certification, carbon credits, and white-label cascade engine for global markets.
            </p>
          </div>
          <div className="flex md:justify-end">
            <a href="mailto:invest@annva.in" className="inline-flex items-center gap-2 rounded-full border border-cream/30 bg-cream/5 px-6 py-3 text-sm hover:bg-cream/15 transition-colors">
              Request data room <ArrowRight className="h-4 w-4" />
            </a>
          </div>
        </div>
      </section>
    </div>
  );
}
