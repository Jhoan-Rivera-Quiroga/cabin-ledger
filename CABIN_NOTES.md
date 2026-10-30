# Cabin Ledger — Project Notes

A rural tourist cabin version of the CasaBerry "Ledger" app. Same approach: one self-contained HTML file (React + Babel in the browser, Chart.js, SheetJS), no build step.

## Files

- **`index.html`** — the whole app (named index.html so a static host serves it at the site root). Open it directly for a quick look, or deploy the whole folder.
- **`cabin-schema.sql`** — only needed for Supabase mode (shared data across devices).

## Tabs

| Tab | Purpose |
|---|---|
| Dashboard | From/To date filter (defaults to the current year; "This year", "Last 12 months", "Clear dates" for everything). Revenue, expenses, net, occupancy, average nightly rate; revenue-vs-expenses and occupancy charts, each with a Weekly / Monthly / Yearly switch (weeks run Sun–Sat, labelled W1, W2…; W1 is the week containing January 1st) |
| Bookings | Entry form only: guest, cabin, dates, channel, **Total** (what you actually receive), payment method, notes. Blocks double-bookings per cabin |
| Expenses | Entry form only: date, category (with inline "Manage list"), description, amount, optional "spread over N months" |
| Records | Switch between Bookings / Expenses, filter by date range, cabin or category, search; edit, delete, Excel export |
| Settings | Cabins, booking channels, data export / local backup |

## Logic worth knowing

- **No booking status.** Every saved booking counts. To cancel, delete it in Records. (Existing local data saved by the first version may still carry a hidden `status` — it is ignored.)
- **Revenue recognition** (`computeRange`): the booking Total is split evenly across its nights (remainder on the last night), so a stay crossing a month end is split. Expenses spread over N months are split evenly; only the shares inside the chosen date range count.
- **Occupancy KPI** = nights sold up to today ÷ (cabins × days elapsed in the range). The monthly chart includes future bookings.
- **Check-out day is free**: a stay occupies nights `checkIn … checkOut-1`, so a same-day turnover is not a conflict.
- Records date filters: bookings by check-in day, expenses by payment date.
- Money is whole numbers in `CURRENCY` (COP, formatted es-CO, top of the script).

## Storage

- `SUPABASE_URL` / `SUPABASE_ANON_KEY` at the top of the script are empty → **local mode** (browser `localStorage`, one computer). Fill them in and run `cabin-schema.sql` to switch to Supabase.
- In Supabase mode the app shows a login screen. Bookings hold guest names and phone numbers, so the schema's RLS policies require a signed-in user (CasaBerry's are wide open). Create users in Supabase → Authentication and turn off public sign-ups.

## Known limits

- Local mode data lives in one browser; clearing site data deletes it. Use Settings → Download backup.
- No realtime sync, last write wins (same as CasaBerry).
- Supabase mode (login + shared storage) has **not been tested against a live project** — only local mode was exercised.
- Removed on request: calendar, tasks, booking status, platform-fee tracking (log a fee you pay separately as an expense). Not built: seasonal pricing, taxes/VAT, iCal sync.

## Installable phone app (PWA)

The folder is a Progressive Web App: `index.html` + `manifest.webmanifest` + `sw.js` + `icon-192.png`, `icon-512.png`, `apple-touch-icon.png`. Deploy **the whole folder** (e.g. Netlify → Deploys → drag the folder; `index.html` must be at its root).

- Needs **HTTPS**. The manifest and service worker do not work from `file://`.
- **Rename the Netlify site before anyone installs it** (Site configuration → Change site name). The installed icon is tied to the URL; renaming later means reinstalling.
- Install: iPhone = open in **Safari** → Share → Add to Home Screen. Android = Chrome → menu → Install app.
- `sw.js` caches only the CDN libraries (React, Chart.js…), never the page or the data, so the app can't open as a stale copy.
- Phone layout (≤768 px): the tab bar moves to a bottom bar, inputs are 16 px (no iPhone zoom), toasts sit above the bar. Wide screens are unchanged. Everything is in one `@media` block in the `<style>`.
- The icons are **placeholders** (cream cabin on green). Replace the three PNGs when the design is decided.
- **Use Supabase mode on phones.** In local mode each browser — and the installed home-screen app — has its own separate storage, so a phone and a laptop would not share bookings, and iOS can clear storage of rarely used web apps.
- Set `TIME_ZONE` (top of the script, e.g. `'America/Bogota'`) so "today" follows the cabin's clock rather than the device's.

### Honest saving (Supabase mode)

- Every write is refused up front while offline: "No internet connection - nothing was saved."
- A failed save keeps the form open with everything still typed and shows the error inside the form (and as a toast).
- Lists and tables change only after the database confirms the write; no optimistic updates.
- A failed read never counts as "no data": a red banner with Retry appears, and the default lists are only seeded after a read that *succeeded* and found nothing.
- An orange banner shows while offline; data reloads automatically when the connection returns.
