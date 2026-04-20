import { useState } from "react";
import { PartyPopper, CheckCircle2, Calendar, Users, Award } from "lucide-react";

export default function EventsPage() {
  const [submitted, setSubmitted] = useState(false);

  return (
    <div className="container py-10">
      <div className="max-w-3xl">
        <p className="text-xs uppercase tracking-[0.25em] text-ochre">Zero-Waste Certification</p>
        <h1 className="mt-2 font-serif text-4xl md:text-6xl text-primary leading-tight">
          Your wedding, conference, or banquet — without the waste.
        </h1>
        <p className="mt-5 text-lg text-muted-foreground">
          Register your event. We pre-assign volunteers, route surplus to NGOs in real time, and issue a verified Zero-Waste Certificate within 72 hours.
        </p>
      </div>

      <div className="mt-12 grid gap-8 lg:grid-cols-[1.2fr_1fr]">
        {/* How it works */}
        <div>
          <h2 className="font-serif text-3xl text-primary">How it works</h2>
          <ol className="mt-6 space-y-5">
            {[
              { icon: Calendar, t: "Register the event", d: "Date, venue, expected guests, caterer. We'll assign a city coordinator." },
              { icon: Users, t: "Volunteers pre-deployed", d: "2–6 trained volunteers on-site for the final 90 minutes of service." },
              { icon: PartyPopper, t: "Surplus flows live", d: "Cascade engine routes leftovers to nearest NGOs. Real-time tracking shared with hosts." },
              { icon: Award, t: "Certificate issued", d: "Independently audited PDF + public verification link. Share on socials, attach to ESG reports." },
            ].map((s, i) => (
              <li key={s.t} className="flex gap-5">
                <div className="shrink-0 h-12 w-12 rounded-full bg-primary text-primary-foreground flex items-center justify-center">
                  <s.icon className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <div className="flex items-baseline gap-3">
                    <span className="font-mono text-xs text-ochre-deep">0{i + 1}</span>
                    <h3 className="font-serif text-xl text-primary">{s.t}</h3>
                  </div>
                  <p className="text-sm text-muted-foreground mt-1">{s.d}</p>
                </div>
              </li>
            ))}
          </ol>

          {/* Sample report */}
          <div className="mt-10 rounded-2xl border border-ochre/40 bg-gradient-to-br from-ochre/10 to-transparent p-6">
            <p className="text-xs uppercase tracking-widest text-ochre-deep">Sample post-event report</p>
            <h3 className="mt-3 font-serif text-2xl text-primary">Sharma–Patel Wedding · Taj West End · Mar 14, 2026</h3>
            <div className="mt-4 grid grid-cols-2 sm:grid-cols-4 gap-4">
              <Metric label="Guests" v="420" />
              <Metric label="Kg rescued" v="68" />
              <Metric label="Meals routed" v="240" />
              <Metric label="NGOs served" v="3" />
            </div>
            <p className="mt-4 text-sm text-muted-foreground">
              Surplus distributed across Akshaya Patra, Robin Hood Army, and Goonj. CO₂ avoided: 172 kg.
            </p>
          </div>
        </div>

        {/* Form */}
        <div>
          <div className="rounded-2xl border border-border bg-cream-light p-6 sticky top-24">
            <h3 className="font-serif text-2xl text-primary">Register your event</h3>
            <p className="text-sm text-muted-foreground mt-1">Free for personal events. ₹2,500 flat for corporate.</p>

            {submitted ? (
              <div className="mt-6 rounded-xl border border-cascade-fresh/40 bg-cascade-fresh/10 p-5 animate-fade-in">
                <CheckCircle2 className="h-6 w-6 text-cascade-fresh" />
                <p className="mt-3 font-serif text-xl text-primary">Registered.</p>
                <p className="mt-1 text-sm text-muted-foreground">Our Bengaluru coordinator will WhatsApp you within 4 hours.</p>
              </div>
            ) : (
              <form onSubmit={(e) => { e.preventDefault(); setSubmitted(true); }} className="mt-5 space-y-3">
                <Input label="Event name" placeholder="e.g. Annual gala" />
                <div className="grid grid-cols-2 gap-3">
                  <Input label="Date" type="date" />
                  <Input label="Guests" type="number" placeholder="120" />
                </div>
                <Input label="Venue" placeholder="Hotel / location" />
                <Input label="Caterer" placeholder="Optional" />
                <Input label="WhatsApp number" placeholder="+91" />
                <button className="w-full rounded-full bg-primary text-primary-foreground py-3 text-sm hover:bg-indigo-deep transition-colors">
                  Register event
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function Metric({ label, v }: { label: string; v: string }) {
  return (
    <div>
      <p className="text-[10px] uppercase tracking-widest text-muted-foreground">{label}</p>
      <p className="font-serif text-3xl text-primary tabular-nums">{v}</p>
    </div>
  );
}

function Input({ label, ...props }: { label: string } & React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <label className="block">
      <span className="text-[10px] uppercase tracking-widest text-muted-foreground">{label}</span>
      <input {...props} className="mt-1 w-full rounded-md border border-border bg-background px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-ring" />
    </label>
  );
}
