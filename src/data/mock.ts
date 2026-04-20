// Annva — mock data for showcase MVP. Bangalore-centric.

export type CascadeStage = "fresh" | "mid" | "urgent";

export interface FoodListing {
  id: string;
  name: string;
  seller: string;
  vertical: "Restaurant" | "Kirana" | "Bakery" | "Event" | "Corporate";
  diet: ("veg" | "jain" | "halal" | "non-veg")[];
  qtyKg: number;
  servings: number;
  originalPrice: number;
  currentPrice: number;
  stage: CascadeStage;
  hoursLeft: number;
  lat: number;
  lng: number;
  address: string;
  imageHint: string;
}

export const SELLERS = [
  { name: "MTR — Lalbagh", vertical: "Restaurant", area: "Lalbagh", rescued: 1842, score: 4.9 },
  { name: "Third Wave Coffee — Indiranagar", vertical: "Restaurant", area: "Indiranagar", rescued: 967, score: 4.8 },
  { name: "BBK Bakery", vertical: "Bakery", area: "Jayanagar", rescued: 2310, score: 4.9 },
  { name: "Reliance Fresh — Koramangala", vertical: "Kirana", area: "Koramangala", rescued: 4120, score: 4.7 },
  { name: "Iyengar's Bakery", vertical: "Bakery", area: "Malleshwaram", rescued: 1503, score: 4.8 },
  { name: "Nandhini Deluxe", vertical: "Restaurant", area: "JP Nagar", rescued: 880, score: 4.6 },
  { name: "More Supermarket — HSR", vertical: "Kirana", area: "HSR Layout", rescued: 3211, score: 4.7 },
  { name: "Wipro Café — Sarjapur", vertical: "Corporate", area: "Sarjapur", rescued: 2845, score: 4.9 },
  { name: "Taj West End — Banquets", vertical: "Event", area: "Race Course Rd", rescued: 1206, score: 5.0 },
  { name: "Brahmins' Coffee Bar", vertical: "Restaurant", area: "Shankarapuram", rescued: 612, score: 4.8 },
  { name: "Daily Bread", vertical: "Bakery", area: "Lavelle Rd", rescued: 1789, score: 4.9 },
  { name: "BigBasket Hub — Whitefield", vertical: "Kirana", area: "Whitefield", rescued: 5240, score: 4.8 },
] as const;

export const LISTINGS: FoodListing[] = [
  { id: "L01", name: "Bisi bele bath (catered)", seller: "MTR — Lalbagh", vertical: "Restaurant", diet: ["veg"], qtyKg: 8, servings: 32, originalPrice: 2400, currentPrice: 480, stage: "urgent", hoursLeft: 1.4, lat: 12.9507, lng: 77.5848, address: "Lalbagh Main Rd", imageHint: "rice" },
  { id: "L02", name: "Croissants & danish (24 pcs)", seller: "BBK Bakery", vertical: "Bakery", diet: ["veg"], qtyKg: 3.2, servings: 24, originalPrice: 1800, currentPrice: 360, stage: "urgent", hoursLeft: 0.8, lat: 12.9250, lng: 77.5938, address: "11th Main, Jayanagar", imageHint: "bakery" },
  { id: "L03", name: "Vegetable thali plates", seller: "Nandhini Deluxe", vertical: "Restaurant", diet: ["veg"], qtyKg: 6, servings: 18, originalPrice: 2700, currentPrice: 810, stage: "mid", hoursLeft: 4.2, lat: 12.9081, lng: 77.5831, address: "JP Nagar 4th Phase", imageHint: "thali" },
  { id: "L04", name: "Cold-pressed juices (40 btl)", seller: "Third Wave Coffee — Indiranagar", vertical: "Restaurant", diet: ["veg"], qtyKg: 12, servings: 40, originalPrice: 6000, currentPrice: 1500, stage: "mid", hoursLeft: 5.5, lat: 12.9719, lng: 77.6412, address: "100ft Rd, Indiranagar", imageHint: "juice" },
  { id: "L05", name: "Fresh produce bundle", seller: "Reliance Fresh — Koramangala", vertical: "Kirana", diet: ["veg", "jain"], qtyKg: 22, servings: 60, originalPrice: 4400, currentPrice: 2200, stage: "fresh", hoursLeft: 9.2, lat: 12.9352, lng: 77.6245, address: "80ft Rd, Koramangala", imageHint: "produce" },
  { id: "L06", name: "Wedding banquet surplus", seller: "Taj West End — Banquets", vertical: "Event", diet: ["veg", "non-veg"], qtyKg: 45, servings: 120, originalPrice: 0, currentPrice: 0, stage: "urgent", hoursLeft: 1.1, lat: 12.9885, lng: 77.5872, address: "Race Course Rd", imageHint: "banquet" },
  { id: "L07", name: "Bread loaves (assorted)", seller: "Iyengar's Bakery", vertical: "Bakery", diet: ["veg"], qtyKg: 5.5, servings: 30, originalPrice: 1500, currentPrice: 300, stage: "urgent", hoursLeft: 1.7, lat: 13.0035, lng: 77.5709, address: "Sampige Rd, Malleshwaram", imageHint: "bread" },
  { id: "L08", name: "Corporate lunch boxes", seller: "Wipro Café — Sarjapur", vertical: "Corporate", diet: ["veg"], qtyKg: 18, servings: 70, originalPrice: 8400, currentPrice: 2100, stage: "mid", hoursLeft: 3.6, lat: 12.9001, lng: 77.6883, address: "Sarjapur Rd", imageHint: "lunch" },
  { id: "L09", name: "Idli batter & chutneys", seller: "Brahmins' Coffee Bar", vertical: "Restaurant", diet: ["veg"], qtyKg: 7, servings: 28, originalPrice: 1400, currentPrice: 420, stage: "mid", hoursLeft: 4.8, lat: 12.9521, lng: 77.5663, address: "Shankarapuram", imageHint: "idli" },
  { id: "L10", name: "Pizzas & pastas (catered)", seller: "Daily Bread", vertical: "Bakery", diet: ["veg"], qtyKg: 9, servings: 36, originalPrice: 5400, currentPrice: 1080, stage: "urgent", hoursLeft: 0.5, lat: 12.9719, lng: 77.5946, address: "Lavelle Rd", imageHint: "pizza" },
  { id: "L11", name: "Dairy & paneer", seller: "BigBasket Hub — Whitefield", vertical: "Kirana", diet: ["veg"], qtyKg: 14, servings: 50, originalPrice: 3500, currentPrice: 1750, stage: "fresh", hoursLeft: 8.3, lat: 12.9698, lng: 77.7500, address: "Whitefield Main", imageHint: "dairy" },
  { id: "L12", name: "Sandwich platters", seller: "More Supermarket — HSR", vertical: "Kirana", diet: ["veg"], qtyKg: 4.5, servings: 20, originalPrice: 1600, currentPrice: 640, stage: "mid", hoursLeft: 3.0, lat: 12.9116, lng: 77.6473, address: "27th Main, HSR", imageHint: "sandwich" },
];

export const VOLUNTEERS = [
  { name: "Aarav Iyer", tier: "Gold", rescues: 142, kg: 1820, city: "Bangalore" },
  { name: "Priya Subramanian", tier: "Silver", rescues: 87, kg: 1104, city: "Bangalore" },
  { name: "Rohan Desai", tier: "Bronze", rescues: 23, kg: 290, city: "Bangalore" },
  { name: "Ananya Rao", tier: "Chapter Lead", rescues: 318, kg: 4012, city: "Bangalore" },
  { name: "Karthik Menon", tier: "Gold", rescues: 156, kg: 1973, city: "Bangalore" },
  { name: "Sneha Pillai", tier: "Silver", rescues: 64, kg: 805, city: "Bangalore" },
  { name: "Vikram Bhat", tier: "Bronze", rescues: 11, kg: 138, city: "Bangalore" },
  { name: "Meera Krishnan", tier: "Chapter Lead", rescues: 402, kg: 5103, city: "Bangalore" },
];

export const NGOS = [
  { name: "Akshaya Patra Foundation", beneficiaries: 1840000, partner: true },
  { name: "Robin Hood Army", beneficiaries: 920000, partner: true },
  { name: "Feeding India by Zomato", beneficiaries: 1200000, partner: true },
  { name: "Goonj", beneficiaries: 540000, partner: true },
  { name: "The Better India Cares", beneficiaries: 88000, partner: false },
];

export const TIER_REQS = {
  Bronze: { min: 5, color: "hsl(30 65% 42%)" },
  Silver: { min: 50, color: "hsl(220 8% 60%)" },
  Gold: { min: 125, color: "hsl(36 78% 57%)" },
  "Chapter Lead": { min: 250, color: "hsl(213 52% 24%)" },
} as const;

export const LIVE_IMPACT = {
  kgRescued: 487_312,
  mealsDelivered: 1_948_240,
  co2Saved: 1_236_478,
  sellersOnboarded: 1_240,
  volunteersActive: 3_890,
  citiesLive: 6,
};

export function formatINR(n: number) {
  if (n === 0) return "Free";
  return "₹" + n.toLocaleString("en-IN");
}

export function stageLabel(s: CascadeStage) {
  return s === "fresh" ? "Fresh — 20% off" : s === "mid" ? "Cascade — 50% off" : "Final hour — Free pickup";
}

export function stageColor(s: CascadeStage) {
  return s === "fresh" ? "cascade-fresh" : s === "mid" ? "cascade-mid" : "cascade-urgent";
}
