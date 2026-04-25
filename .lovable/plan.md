
# Annva — Food That Moves 🌾

A showcase MVP for India's AI-powered food rescue platform. Heritage Indigo design (cream + indigo + ochre), investor-demo ready with realistic mock data across all four user personas.

## Design system
- **Palette:** Cream `#F5F0E5` base, Deep Indigo `#1E3A5F` / Ink `#0D1B2A` for text & primary, Ochre `#E8A33D` as the urgency accent
- **Type:** Instrument Serif for hero/section heads (editorial gravitas), Work Sans for UI/body
- **Motifs:** Devanagari "अन्न" watermark accents, hand-drawn grain divider, soft paper texture, subtle ochre "urgency pulse" animation, generous whitespace

## 1. Public landing page (`/`)
- Hero: "Food That Moves." with animated countdown chip ("Free pickup in 1h 47m") + Devanagari mark
- The Paradox: side-by-side stats — 78M tonnes wasted vs 194M undernourished (animated counters)
- **Urgency Cascade Engine** — interactive 3-stage visual (12h → 6h → 2h → free pickup) with timeline scrubber
- Five verticals (Restaurants, Kiranas, Bakeries, Events, Corporate) as illustrated cards
- Live impact ticker (kg rescued, meals delivered, CO₂ saved — animating in real time)
- Volunteer certification preview (Bronze → Chapter Lead tiers)
- Investor strip (₹1.52 lakh crore market, ₹1.5–2 Cr seed)
- Footer with NCC/NYKS/NSS partner logos, waitlist email capture

## 2. Live Urgency Heatmap (`/map`)
Real Leaflet/OpenStreetMap (no API key needed) of a demo city (Bangalore):
- Color-coded pins: green (12–6h), amber (6–2h), red (<2h free pickup)
- Click pin → side drawer with food details, seller, qty, original/current price, countdown
- Filter: vertical, dietary (veg/jain/halal), distance radius, price
- "Reserve" / "Volunteer to pickup" CTAs
- Live cluster batching visualization for volunteer routes

## 3. Consumer dashboard (`/consumer`)
- Discover feed of nearby discounted items with live countdowns
- Active orders, saved sellers, reorder
- **Personal impact card**: meals saved, kg rescued, CO₂ avoided, ₹ saved
- Annva Wallet & order history

## 4. Seller dashboard (`/seller`)
For restaurants/kiranas/bakeries:
- "List surplus" flow — photo upload (mock OCR auto-fills name/expiry/price), batch listing
- Live inventory with cascade stage badges and auto-pricing curve chart
- Today's recovery: ₹ recovered vs would-have-wasted
- AlchemyScore (kirana credit) widget, BRSR/ESG export button
- Predictive Waste Intelligence panel (SaaS upsell)

## 5. Volunteer dashboard (`/volunteer`)
- Available rescues nearby with batch routes on a mini-map
- Active pickup with NGO drop-off and proof-of-delivery photo
- **Certification progress** — Bronze/Silver/Gold/Chapter Lead with progress rings
- Verified credentials wall: every rescue timestamped, geotagged, NGO-confirmed (blockchain-style hash badges)
- LinkedIn share, NCC/NSS/NAAC export buttons, leaderboard
- Food safety training modules

## 6. Food Givers (Sellers) directory (`/givers`)
Public showcase of partner sellers — searchable, filterable by city/vertical, with each seller's verified rescue stats and impact badges.

## 7. NGO / Events page (`/ngo` and `/events`)
- NGO portal: incoming pickup queue, beneficiaries served, weekly heatmap of need
- Events: register a wedding/corporate event for Zero-Waste Certificate, pre-volunteer assignment, post-event impact report

## 8. Impact & Certification page (`/impact`)
- Year 1/2/3 verified metrics (kg, meals, CO₂, sellers, volunteers)
- SDG alignment cards (2, 12, 13, 1, 17)
- Live transaction-level audit feed
- Carbon credit & BRSR certification download mockups
- Public verification: paste a certificate ID → verify

## Navigation
Persistent top nav with role switcher (Consumer / Seller / Volunteer / NGO) so investors can preview every dashboard instantly. Mobile-responsive with hamburger.

## Mock data
Realistic Indian sellers (Bangalore: MTR, Third Wave Coffee, BBK Bakery, Reliance Fresh kiranas), authentic food items, INR pricing, Indian volunteer names, NGOs (Akshaya Patra, Robin Hood Army, Feeding India).
