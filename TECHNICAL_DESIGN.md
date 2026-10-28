# Annva — Technical Design Document

## 1. Problem Statement

India wastes millions of tonnes of edible food every year while millions of people face food insecurity. The waste is concentrated at the end of the day: restaurants, bakeries, temples and event kitchens hold cooked, perishable surplus with only hours of safe shelf life, and there is no fast, trusted channel to move it to nearby consumers or NGOs before it spoils.

Annva is an AI-powered surplus food rescue platform that bridges this gap. It connects **Sellers** (restaurants, bakeries, temples, event kitchens) with **Consumers** and **NGOs**, using time-based pricing and a volunteer delivery network so good food is rescued instead of discarded.

## 2. Users and Roles

| Role | What they do |
|---|---|
| Seller | Lists excess items with photo, price and time of preparation; confirms or denies incoming orders |
| Consumer | Browses available surplus nearby, rescues items via cart and digital payment |
| Volunteer | Accepts nearby delivery tasks, picks up food from the seller, delivers to the NGO, confirms with a photo |
| NGO | Receives rescued food through volunteer deliveries (and the NGO Rescue Fund) |

## 3. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App (Annva)                       │
│   Riverpod 2 state management  ·  GoRouter navigation            │
│   Screens: role select, seller dashboard, consumer dashboard,    │
│   listing, cart, payment, volunteer tasks, delivery proof        │
└──────┬──────────────────┬───────────────────┬────────────────────┘
       │                  │                   │
       ▼                  ▼                   ▼
┌─────────────┐   ┌──────────────┐   ┌──────────────────────────┐
│ Firebase    │   │ Firebase     │   │ On-device AI             │
│ Auth        │   │ Firestore +  │   │ EfficientNet-B3 (ONNX)   │
│ (OTP login  │   │ Realtime DB  │   │ Food recognition /       │
│  via mobile)│   │ Listings,    │   │ freshness assessment     │
│             │   │ orders,      │   │ for listed items         │
│             │   │ volunteer    │   │                          │
│             │   │ tasks,       │   │                          │
│             │   │ impact stats │   │                          │
└─────────────┘   └──────┬───────┘   └──────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │ Notifications        │
              │ New order → seller   │
              │ Order status →       │
              │ consumer             │
              │ Nearby task →        │
              │ volunteers           │
              └──────────────────────┘
```

**Tech stack:** Flutter · Riverpod 2 (Notifier style) · GoRouter · Firebase (Firestore, Realtime Database, Auth) · ONNX model (EfficientNet-B3) · Heritage Indigo & Ochre design system.

## 4. Key Features and How They Work

- **Live Cascade Pricing:** the price of a listed item drops automatically as its safe consumption window elapses, so sellers recover value and consumers get a reason to rescue quickly.
- **Price Lock:** a consumer can freeze the current cascade price for 20 minutes with a small deposit.
- **Prasad Protocol:** surplus from temples, gurudwaras and mosques is rescued through a dedicated flow that respects religious handling.
- **NGO Rescue Fund:** forfeited price-lock deposits are repurposed to fund logistics for NGO partners.
- **Impact Ticker:** live tracking of kilograms rescued and meals delivered across India.
- **Free Rescue trigger:** when an item crosses its time limit (e.g. 2 hours before expiry, or unsold at end of day), its status flips to free rescue and nearby volunteers are notified.
- **Volunteer delivery loop:** nearby assignment → accept → pick up from seller → deliver to NGO → complete with photo/confirmation upload.
- **Order lifecycle:** order placed (pending seller confirmation) → seller confirms or denies → both parties notified; a denial notifies the consumer and frees the item.

## 5. User Flow

See **Figure 1 — Annva user flow** (`annva-user-flow.jpg` in this package): app start → OTP login → role selection (Seller / Consumer / NGO) → seller dashboard (list excess items) → consumer dashboard (view listed items, rescue via cart, digital payment) → seller order confirmation → volunteer notification, acceptance, pickup and NGO delivery with photo confirmation. The free-rescue branch triggers when an item's time limit is exceeded.

## 6. Data Model (Firestore, indicative)

- `users` — uid, role (seller / consumer / volunteer / ngo), phone, location
- `listings` — seller id, photo, title, price, cascade state, preparedAt, expiryAt, status (available / locked / rescued / free-rescue / expired)
- `orders` — listing id, consumer id, status (pending / confirmed / denied / completed), payment ref
- `volunteerTasks` — listing/order id, volunteer id, status (notified / accepted / picked / delivered), proof photo
- `impact` — aggregate kilograms rescued, meals delivered

## 7. Setup and Environment Variables

1. Clone the repository.
2. Run `flutter pub get`.
3. Copy `.env.example` to `.env` and fill in the Firebase configuration values (API key, project id, messaging sender id, app id) and any payment-gateway keys. Never commit a filled `.env` — it is git-ignored.
4. Launch on Android/iOS/Web using `flutter run`.

See `README-PATCH.md` in this package for the exact README section to add.

## 8. Testing

- `test/widget_test.dart` — widget smoke test (baseline; extend before submission with tests for cascade pricing, order-status transitions and the free-rescue trigger).
- `sample-data/` in this package — sample listings, users and an order that can be loaded to demo the full flow without real sellers or payments.

## 9. Limitations and Future Work

- Payments and NGO onboarding flows are demo-stage; production use needs a licensed payment gateway and NGO verification.
- The ONNX model currently assists listing; full automated freshness grading is future work.
- Volunteer coverage is location-dependent; the free-rescue branch only works where volunteers are active.
- NGO-side screens (own dashboard, acceptance flow) are thinner than the seller/consumer flows and are the next build priority.

## 10. License

Open source under the MIT License — see `LICENSE` in this package. (This replaces the previous "Proprietary" notice in the README.)
