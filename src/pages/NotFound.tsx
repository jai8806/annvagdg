import { Link } from "react-router-dom";

export default function NotFound() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background p-6">
      <span className="font-devanagari text-9xl text-primary/20">अन्न</span>
      <h1 className="mt-6 font-serif text-6xl text-primary">404</h1>
      <p className="mt-3 text-muted-foreground">This page has gone to the cascade.</p>
      <Link to="/" className="mt-6 rounded-full bg-primary text-primary-foreground px-6 py-2.5 text-sm hover:bg-indigo-deep transition-colors">
        Back home
      </Link>
    </div>
  );
}
