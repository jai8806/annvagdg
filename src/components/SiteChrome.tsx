import { NavLink as RouterNavLink, useLocation } from "react-router-dom";
import { useState } from "react";
import { Menu, X } from "lucide-react";
import { cn } from "@/lib/utils";

const links = [
  { to: "/", label: "Home" },
  { to: "/map", label: "Live Heatmap" },
  { to: "/givers", label: "Food Givers" },
  { to: "/impact", label: "Impact" },
  { to: "/events", label: "Events" },
];

const roles = [
  { to: "/consumer", label: "Consumer" },
  { to: "/seller", label: "Seller" },
  { to: "/volunteer", label: "Volunteer" },
  { to: "/ngo", label: "NGO" },
];

export function SiteHeader() {
  const [open, setOpen] = useState(false);
  const location = useLocation();
  const activeRole = roles.find((r) => location.pathname.startsWith(r.to));

  return (
    <header className="sticky top-0 z-40 w-full border-b border-border/60 bg-cream/85 backdrop-blur-md">
      <div className="container flex h-16 items-center justify-between gap-4">
        <RouterNavLink to="/" className="flex items-center gap-2 group">
          <span className="font-devanagari text-2xl text-primary leading-none">अन्न</span>
          <span className="font-serif text-2xl text-primary leading-none">Annva</span>
        </RouterNavLink>

        <nav className="hidden lg:flex items-center gap-7">
          {links.map((l) => (
            <RouterNavLink
              key={l.to}
              to={l.to}
              end={l.to === "/"}
              className={({ isActive }) =>
                cn("text-sm tracking-wide editorial-link", isActive ? "text-primary font-medium" : "text-muted-foreground hover:text-primary")
              }
            >
              {l.label}
            </RouterNavLink>
          ))}
        </nav>

        <div className="hidden md:flex items-center gap-2">
          <div className="flex items-center gap-1 rounded-full border border-border bg-cream-light p-1">
            <span className="px-2 text-[10px] uppercase tracking-widest text-muted-foreground">Demo as</span>
            {roles.map((r) => (
              <RouterNavLink
                key={r.to}
                to={r.to}
                className={({ isActive }) =>
                  cn(
                    "rounded-full px-3 py-1 text-xs transition-colors",
                    isActive ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-primary"
                  )
                }
              >
                {r.label}
              </RouterNavLink>
            ))}
          </div>
        </div>

        <button onClick={() => setOpen(!open)} className="lg:hidden p-2 -mr-2" aria-label="Menu">
          {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {open && (
        <div className="lg:hidden border-t border-border/60 bg-cream animate-fade-in">
          <div className="container py-4 flex flex-col gap-1">
            {[...links, ...roles].map((l) => (
              <RouterNavLink
                key={l.to}
                to={l.to}
                end={l.to === "/"}
                onClick={() => setOpen(false)}
                className={({ isActive }) =>
                  cn(
                    "py-2.5 px-3 rounded-md text-sm",
                    isActive ? "bg-secondary text-primary font-medium" : "text-muted-foreground"
                  )
                }
              >
                {l.label}
                {roles.includes(l as any) && <span className="ml-2 text-[10px] uppercase tracking-widest text-ochre">role</span>}
              </RouterNavLink>
            ))}
            {activeRole && (
              <p className="mt-2 px-3 text-xs text-muted-foreground">Currently demoing: <span className="text-primary font-medium">{activeRole.label}</span></p>
            )}
          </div>
        </div>
      )}
    </header>
  );
}

export function SiteFooter() {
  return (
    <footer className="mt-24 border-t border-border/60 bg-cream-light">
      <div className="container py-14 grid gap-10 md:grid-cols-4">
        <div className="md:col-span-2">
          <div className="flex items-center gap-2">
            <span className="font-devanagari text-3xl text-primary">अन्न</span>
            <span className="font-serif text-3xl text-primary">Annva</span>
          </div>
          <p className="mt-3 max-w-md text-sm text-muted-foreground leading-relaxed">
            Food that moves. India's intelligent rescue network — from surplus to plate, before it spoils.
          </p>
          <form
            onSubmit={(e) => { e.preventDefault(); alert("Thank you — you're on the waitlist."); }}
            className="mt-5 flex w-full max-w-sm items-center gap-2"
          >
            <input
              type="email"
              required
              placeholder="you@city.in"
              className="flex-1 rounded-full border border-border bg-background px-4 py-2 text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            />
            <button className="rounded-full bg-primary px-4 py-2 text-sm text-primary-foreground hover:bg-indigo-deep transition-colors">
              Join waitlist
            </button>
          </form>
        </div>

        <div>
          <h4 className="text-xs uppercase tracking-widest text-ochre">Platform</h4>
          <ul className="mt-3 space-y-2 text-sm text-muted-foreground">
            <li><RouterNavLink to="/map" className="editorial-link">Live heatmap</RouterNavLink></li>
            <li><RouterNavLink to="/givers" className="editorial-link">Food givers</RouterNavLink></li>
            <li><RouterNavLink to="/volunteer" className="editorial-link">Volunteer</RouterNavLink></li>
            <li><RouterNavLink to="/impact" className="editorial-link">Impact</RouterNavLink></li>
          </ul>
        </div>

        <div>
          <h4 className="text-xs uppercase tracking-widest text-ochre">Partners</h4>
          <ul className="mt-3 space-y-2 text-sm text-muted-foreground">
            <li>NCC · National Cadet Corps</li>
            <li>NYKS · Nehru Yuva Kendra</li>
            <li>NSS · National Service Scheme</li>
            <li>Akshaya Patra · Robin Hood Army</li>
          </ul>
        </div>
      </div>
      <div className="border-t border-border/60">
        <div className="container py-5 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-muted-foreground">
          <p>© {new Date().getFullYear()} Annva Foundation · Bengaluru, India</p>
          <p className="font-devanagari">अन्न ही ब्रह्म है</p>
        </div>
      </div>
    </footer>
  );
}
