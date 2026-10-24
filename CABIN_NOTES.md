# Cabin Ledger — Project Notes

A rural tourist cabin version of the CasaBerry "Ledger" app. Same approach: one self-contained HTML file (React + Babel in the browser, Chart.js, SheetJS), no build step.

## Files

- **`cabin-ledger.html`** — the whole app. Double-click to open, or host as a static file (e.g. Netlify drag-and-drop).
- **`cabin-schema.sql`** — only needed for Supabase mode (shared data across devices).

## What it does

| Tab | Purpose |
|---|---|
| Dashboard | Yearly revenue, expenses, net, occupancy, average nightly rate, balances due; revenue-vs-expenses and occupancy charts; arrivals/departures for the next 14 days; open tasks |
| Calendar | Month view, one row per cabin; click a booking to edit it |
| Bookings | Guest, cabin, dates, rate, cleaning fee, channel commission, status, payments. Blocks double-bookings per cabin. "Mark paid" shortcut. Optionally creates a cleaning task for check-out day |
| Expenses | Same idea as CasaBerry costs, incl. spreading a cost over N months (insurance, roof repair…) |
| Tasks | Cleaning / maintenance / supplies to-dos with due date, cabin, assignee |
| Settings | Manage cabins, channels, expense categories, team; Excel export; JSON backup/restore (local mode) |

## Differences from CasaBerry

- **Sales → Bookings.** A booking has a date range, so the app computes nights, totals and overlap checks. Production tracking is gone; Calendar and Tasks replace it.
- **Two storage modes.** `SUPABASE_URL` / `SUPABASE_ANON_KEY` at the top of the script are empty, so it starts in **local mode** (browser `localStorage`, one computer). Fill them in and run `cabin-schema.sql` to switch to Supabase.
- **Login in Supabase mode.** Bookings hold guest names and phone numbers, so the schema's RLS policies require a signed-in user (CasaBerry's are wide open). Create users in Supabase → Authentication and turn off public sign-ups.

## Logic worth knowing

- **Statuses:** Inquiry, Confirmed, Checked in, Completed, Cancelled. Only Confirmed / Checked in / Completed count toward revenue and occupancy (`COUNTED`). Inquiries show on the calendar but don't count; Cancelled bookings free the dates.
- **Revenue recognition** (`computeYear`): nightly rate is attributed night by night, so a stay crossing a month end is split. Cleaning fee and platform commission land in the check-in month.
- **Occupancy KPI** = nights sold up to today ÷ (cabins × days elapsed) for the current year; full year for past years. The monthly chart includes future bookings.
- **Check-out day is free**: a stay occupies nights `checkIn … checkOut-1`, so a same-day turnover is not a conflict.
- Money is whole numbers in `CURRENCY` (default USD, top of the script).

## Known limits

- Local mode data lives in one browser; clearing site data deletes it. Use Settings → Download backup.
- No realtime sync, last write wins (same as CasaBerry).
- Supabase mode (login + shared storage) has **not been tested against a live project** — only local mode was exercised.
- No seasonal pricing, taxes/VAT, deposits schedule, or automatic iCal sync with Airbnb/Booking.com yet.
