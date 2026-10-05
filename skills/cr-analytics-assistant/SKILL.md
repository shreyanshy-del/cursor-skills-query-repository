---
name: cr-analytics-assistant
description: >-
  CR Analytics Assistant for India (IN) — product skills, RCA decision tree,
  causation vs correlation, shopper-spike hierarchy, feature log, CSV schemas,
  and API map for NL conversion-rate root-cause analysis. Use when the user
  asks about CR Analytics Assistant, RCA on CR drops, mix-shift vs operational
  causation, dashboard features, or the Skills/feature log for India CR.
---

> **Geo**: India (IN)
> **Owner**: India PM — edit this file freely to customize for your market
> **Base**: Copied from Master SKILLS.md — modify sections below as needed
> **Related SQL skill**: `cr-analyser` (Iceberg / Data Platform funnel: TIN/SRP, `mri_session_id`)
> **Catalog**: repo-root [`Skills_CR.md`](../../Skills_CR.md)

# CR Analytics Assistant — Skills & Feature Log

All product decisions, business rules, features built, and instructions recorded across conversations.

---

## Platform Overview

**Product**: CR Analytics Assistant for an online bus booking platform
**Purpose**: Allow anyone in the company to ask natural language questions and get RCA (Root Cause Analysis) answers on Conversion Rate drops
**Stack**: Python FastAPI backend + plain HTML/CSS/JS frontend (single-file, no build step)
**Data**: Two CSVs — main aggregated CSV (`feb_data_check2.csv`) + granular slices CSV (`feb_data_check2_with_moreslices.csv`)
**AI**: Claude (claude-sonnet-4-6) with tool-use loop for NL queries
**Future**: Both CSV sources will be replaced with direct DB connections

---

## Business Context

### Booking Funnel (in order)

1. **SRP Sessions** — User searches for a bus route (Search Results Page)
2. **Seat Layout Views** — User opens a specific bus to see the seat map
3. **Customer Info** — User fills passenger details (can add RAP / Free Cancellation / Insurance)
4. **Create Order (Tentative)** — System holds the seat to prevent double-booking
   - ⚠ Tentative Failure = another user booked the same seat simultaneously
5. **Order Info / Payment Page** — User enters payment details
6. **Transaction** — Payment processed
7. **Booking Confirmed** — Final success

> **India SQL alignment (`cr-analyser`)**: SRP → SL → CI → TCO → PAY → PAY_NOW → CONFIRM; **CR = TIN / SRP**; joins on `mri_session_id`; TIN from `transaction.bus_ticket_events` (`event_type=101`, `event_class=2`, `country_code='IND'`). Product identity: CR = ∏ step rates. Prefer that skill for Iceberg queries; use this skill for Assistant/RCA product behaviour.

### Key Metric Definitions

```
CR (Conversion Rate)     = Transactions / SRP Sessions × 100  (expressed as %)
ASP (Avg Selling Price)  = Total GMV / Total Seats             (expressed as ₹ per seat)
Oops Rate                = Oops Sessions / SRP Sessions × 100
SL Failure Rate          = Seat Layout Failures / Seat Layout Sessions × 100
Tentative Error Rate     = Total Tentative Errors / Create Order Sessions × 100
Payment Drop Rate        = 1 - (Transactions / Order Info Sessions) × 100
```

> **ASP logic (v1)**: `total GMV / total_seats`. Simple per-seat revenue proxy. Logic will be revised in a future iteration.

---

## CR Causality Framework & RCA Decision Tree

**CR = Transactions / SRP Sessions**

Both sides of this equation affect CR:
- If **Transactions go down** → CR drops
- If **SRP Sessions go up** (without a proportional rise in transactions) → CR drops

### Decision Tree

```
CR dropped?
│
├── Are SRP Sessions INCREASING?
│   └── Check: Is Oops Rate also increasing?
│       • Oops = users hitting error page before reaching Seat Layout
│       • Rising sessions + rising Oops = more users entering but failing early
│       • Oops spike absorbs traffic, suppressing SL views and downstream conversions
│
└── Are Transactions IMPACTED (flat or falling)?
    └── Check funnel throughputs for the drop point:
        1. SRP → Seat Layout      (check Oops Rate + SL Failure Rate)
        2. Seat Layout → Cust Info (SL quality / availability)
        3. Cust Info → Create Order
        4. Create Order → Order Info (check Tentative Error Rate)
        5. Order Info → Transaction  (check Payment Drop Rate)

        • SL Failures  = users who couldn't load the seat map
        • Tentative Failures = seat held by another user simultaneously
        • Payment Drop = users abandoning at payment stage
```

### How This Drives Alerts & Summary

- **Alert panel**: prioritises anomalies by their position in the above tree. A CR drop triggers checks on both sides — sessions (→ Oops) and transactions (→ funnel stages).
- **Weekly Summary diagnosis**: failure attribution table ranks the 4 error drivers (Oops, SL Fail, Tentative Error, Payment Drop) by their WoW delta contribution.
- **Daily narratives**: identify the worst funnel step; if the drop is at SRP→SL, explicitly call out Oops Rate; if sessions spike, identify which user_type / language drove the traffic.

---

## Causation vs Correlation Framework

When CR drops, the first question is: **is this expected (structural) or unexpected (operational)?**
Answering this prevents false alarms and helps PMs triage correctly.

### Signal Types

| Signal | Type | Meaning |
|--------|------|---------|
| Traffic mix shifted to more guest/new users | Correlation | Guest CR is naturally lower; mix change alone explains the drop |
| More short-DBD searches (0–1 days) in the mix | Correlation | Last-minute shoppers convert lower historically |
| Drop aligns with day-of-week baseline (e.g. CR always dips on Sundays) | Correlation | Structural weekday pattern, not an incident |
| Peak DOJ / festival period bringing in exploratory traffic | Correlation | Seasonal volume spike, lower intent cohort |
| Error rates (Oops, SL Fail, Tentative) spiked beyond historical norm | Causation | Operational failure — action required |
| Funnel broke at a specific step, not explained by mix | Causation | Targeted ops issue |
| A single platform or user_type dropped vs its own baseline | Causation | Segment-specific incident |
| Mix-adjusted expected CR ≈ actual CR | Correlation | Drop fully explained by composition change |
| Mix-adjusted expected CR > actual CR (residual gap) | Causation | Something beyond mix is causing the drop |

### Mix-Shift Decomposition (How to Tell Them Apart)

```
Expected CR = Σ (segment_share_today × segment_CR_last_week)

If Actual CR ≈ Expected CR  →  Structural / Correlation
  "CR dropped because more guest-user traffic came in today;
   each segment performed normally vs last week."

If Actual CR < Expected CR  →  Residual gap = Operational / Causation
  "Even accounting for the mix change, CR is X pp lower than expected.
   Root cause: [error spike / funnel break / segment anomaly]."
```

The residual gap is the number that matters for escalation.

### Decision Flow (Combined with CR Causality Tree)

```
CR dropped vs last week?
│
├── 1. Check traffic mix: did user_type / DBD composition shift?
│      Yes → compute Expected CR; if gap ≤ 0.3pp → likely CORRELATION (structural)
│
├── 2. Check day-of-week baseline: is this weekday historically lower?
│      Yes, within normal band → CORRELATION (seasonal / day pattern)
│
├── 3. Check error rates: did Oops / SL Fail / Tentative spike?
│      Yes, beyond historical norm → CAUSATION (operational)
│
└── 4. Residual: gap not explained by steps 1–3 → investigate further
       (possible: external event, competitor, app change, data issue)
```

### Current Data Limitations & Enhancement Path

**What we can do with current data (Feb 1 – Mar 18, 2026 — ~46 days):**
- Day-of-week comparison: WoW same-day (7 days back) — ✅ implemented
- Mix-shift analysis: user_type and language breakdown available — ✅ can compute expected CR
- Error attribution: Oops, SL Fail, Tentative, Payment Drop — ✅ implemented
- Basic structural vs operational label on daily narrative — ✅ can implement now
- DOJ / DBD correlation: DBD column available in L1 — ⚠ partial (only bucket-level, no raw DOJ date)

> **Limitation**: With only ~6–7 weeks of data, day-of-week baselines are thin (6 observations per weekday max).
> Seasonal patterns (festivals, school holidays, peak travel seasons) cannot be reliably detected yet.
> All "expected CR" baselines are computed from the same 46-day window — which may itself contain anomalies.

**What becomes possible with more data:**

| Data Added | Enhancement Unlocked |
|------------|----------------------|
| 3+ months | Stable day-of-week baselines; weekday vs weekend structural bands |
| 6+ months | Month-over-month seasonal detection; festival effect quantification |
| 1+ year | YoY comparison; peak season identification (summer, Diwali, etc.) |
| DOJ date column | Direct correlation between journey date proximity and CR; peak DOJ impact |
| Route-level data | Route-specific CR benchmarks; tier1 vs pilgrim seasonal patterns |
| Competitor / external event tags | Distinguish external shocks from internal ops failures |

**Recommended next data additions (priority order):**
1. Extend CSV with historical months (Oct–Jan) → enables stable baselines
2. Add raw DOJ date or DOJ category (holiday / regular / festival) → seasonal causality
3. Add route-level data → L1 drill-down for regional/seasonal patterns

### How This Drives the Dashboard

- **Alert panel**: each alert will carry a `type` tag — `operational` (red) vs `structural` (amber) — so PMs know whether to escalate immediately or monitor
- **Daily narrative pills**: will show a "Structural" or "Operational" badge alongside the driver pills
- **Weekly Summary**: failure attribution table will separate mix-driven CR impact from error-driven CR impact

> ⚠ **Note**: Until more historical data is available, structural vs operational classification is based on WoW same-day comparison only. Labels should be treated as indicative, not conclusive.

### Analysis Dimensions (Updated)

| Level | Dimension | Source | Values |
|-------|-----------|--------|--------|
| L0 (Primary) | user_type | Main CSV + Slices | GUEST, NEW, RETURNING |
| L0 | platform / channel | Main CSV + Slices | android, ios, mobile_web, web_direct, others |
| L0 | language | Main CSV + Slices | en, hi, ta, te, kn, mr (India); extend as needed |
| L1 (Drill-down) | region | **Slices CSV** / `lis.config_locations.parent_location` | India states / regions (customize per market map) |
| L1 (Drill-down) | DBD | **Slices CSV** / `search_details` | sameday lmb, sameday non lmb, next day, 2 days, more than 2 days — or 0/1/2/3/4/5+ |
| L1 | route (city) | **Slices CSV** / `search_route_details` | Source city, Destination city |
| L1 | route_length | `lis.short_route_sds` / planned | short / long |
| L1 | operator / BO type | planned / `cr-dim-*` | private, rtc, primo |

> **India dim skills**: `cr-dim-usertype`, `cr-dim-dbd`, `cr-dim-lmb`, `cr-dim-channel`, `cr-dim-region-tier`, `cr-dim-sd-type`, `cr-dim-custom-sd`, `cr-dim-ga-plugin`, `cr-dim-operator`, `cr-dim-bo-type`, `cr-dim-age-gender`, `cr-dim-bus-type`.
> **Note**: Route-type (tier1/tier2/pilgrim) → `return-tier-pilgrim` / Mehar map when connected.

---

## Shopper Spike RCA Hierarchy

**When shoppers (SRP sessions) increase unexpectedly, always follow this 3-step investigation order:**

### Step 1 — Diagnose the Shopper MIX (which type of shoppers increased?)

Check each L1 slice to identify WHERE the spike is concentrated:

| Dimension | What it tells you |
|-----------|-------------------|
| **region** | Which geographic region drove the spike? |
| **DBD bucket** | Are users searching same-day / next-day (low intent) vs advance (high intent)? |
| **user_type** | Guest/new users convert lower; if their share increased → CR drop is expected |
| **channel** | iOS vs Android vs web — different intent and CR baselines |
| **language** | Proxy for market segment |

**Interpretation**: A shopper spike dominated by guest users + sameday DBD = low-intent traffic spike → expect lower CR. A spike in returning users + advance DBD = organic demand growth → investigate other CR drivers.

### Step 2 — Check TRANSACTION MIX QUALITY (did the type of booking change?)

If shoppers increased but CR dropped (or stayed flat), check:

| Metric | Where | What to look for |
|--------|-------|-----------------|
| **ASP** (Avg Selling Price) | Main CSV + Slices | Did ASP fall? Lower ASP = lower-value routes or heavy discounting |
| **RedDeal %** | Main CSV | reddeal_txns / total_txns — spike = promo-hunting traffic attracted by offer |
| **Discount %** | Main CSV + Slices | discount_txns / total_txns — spike = price-sensitive cohort came in |

**Interpretation**: Shoppers up + ASP down + RedDeal% up = promotional campaign attracted deal-seekers. Shoppers up + ASP stable + Discount% flat = organic volume growth.

### Step 3 — Check FUNNEL & ERROR METRICS (if Steps 1-2 don't explain it)

| Metric | What to check |
|--------|--------------|
| SL Failure Rate | Seat layout load failures — availability or tech issue? |
| Oops (Tentative) Rate | Seat hold failures — high-demand routes, concurrency? |
| Payment Drop Rate | Payment gateway, UPI timeout, card decline? |
| Funnel step breakdown | SRP → SL → CInfo → Create → Payment → TXN |

---

## Data Explosion — Why Slices Totals > Main CSV Totals

**Important**: Never directly compare raw session counts between the slices CSV and the main CSV.

**Why counts are higher in the slices data**:
- A "shopper" session = 30 minutes of inactivity defines a session boundary
- If a user searches `Chennai → Bangalore` AND `Bangalore → Chennai` within the same 30-minute session, this creates **2 rows** in the slices data — one for each route, each in their respective regions
- The same explosion applies to DBD: if a user searches 2 routes with different departure dates → 2 DBD bucket entries
- This is correct behaviour — it allows proper attribution of WHICH region/DBD drove the search

**Rule of thumb**:
- Main CSV totals = deduplicated shopper counts (session-level)
- Slices CSV totals = route-level counts (session × route, intentionally higher)
- Always use **CR%** and **relative share** from slices — not absolute session counts

---

## Feature Log

### 1. KPI Cards (Top Row)

7 KPI cards displayed across the top of the dashboard:
- **Conv. Rate** — overall CR for selected period
- **SRP Sessions** — total search sessions
- **Bookings** — completed transactions
- **Error Rate** — create order (tentative) failure rate
- **Payment Drop** — order info → booking drop rate
- **Seats Booked** — total seats booked (yesterday)
- **Seats Lost (est.)** — estimated seats lost due to errors (error sessions × avg seats per txn)

Each KPI shows a **Day-over-Day delta** (▲/▼ with % change vs previous day), colour-coded:
- Green = improvement, Red = degradation

### 2. Daily CR Trend Chart (SVG)

- SVG line chart (orange line with gradient area fill)
- Red anomaly bands highlight error spike days
- Hover tooltips show: date, CR%, bookings count
- Anomaly legend at bottom if spike period detected

### 3. Proactive Auto-Insights Panel

Inside the CR trend card, below the chart. Auto-generated without AI:
- **Spike detection**: flags days where metric > mean + 1.8×std
- **Drop detection**: rolling 7-day average drop
- **Positive trends**: improvements vs baseline
- **Info**: general observations
- Severity: critical (🔴), warning (🟡), positive (🟢), info (📊)

### 4. Step-wise Funnel Throughput Table

Table showing each funnel step with:
- Stage name and step description (e.g. "SL / SRP")
- Session count
- Step conversion rate (colour-coded: green ≥80%, orange 50-80%, red <50%)
- Step drop rate (colour-coded inverse)
- Cumulative conversion from SRP
- Red highlighted rows for drops >50%

### 5. Same-Day Last-Week Comparison Chart

SVG dual-line chart inside the funnel card:
- Orange solid line = current period
- Blue dashed line = same days one week ago
- Shows daily CR% side-by-side for trend alignment
- Red anomaly bands for spike period

### 6. Seats Impact Card

Appears below KPIs when seats data is available:
- "By User Type" table: Seats Booked, Seats Lost, Error Sessions, Loss Rate
- Daily seats trend chart (stacked bar: purple = booked, red = lost on top)
- Shows "Yesterday" as the reference day

**Seats Lost estimation**: `error_sessions × avg_seats_per_txn`
where `avg = total_seats / total_txns` for the period

### 7. Period Comparison Card

Tabbed comparison card with 4 tabs:
- **Day-over-Day (DoD)**: Yesterday vs day before
- **WoW Same Day**: Yesterday vs same day last week (e.g. Mon vs Mon last week)
- **WoW 7-Day**: Last 7 days total vs prior 7 days total
- **Month-over-Month (MoM)**: This month so far vs same # of days last month

Each tab shows a 7-metric grid:
- Conv. Rate, SRP Sessions, Bookings, Error Rate, Payment Drop, Seats Booked, Seats Lost
- Each metric shows: current value, previous value, % change with ▲/▼ (green=good, red=bad)

**Business rationale**: If yesterday was Monday and CR dropped, compare vs last Monday to see if it's a weekday pattern vs a new issue. Helps separate structural (day-of-week) from event-driven drops.

### 8. Dimension Breakdown Table

Tabs for L0 and L1 dimensions. Shows per-segment:
- CR%, SRP Sessions, Bookings, Error Rate, Payment Drop
- Bar chart per segment (relative to max CR)
- Red highlights for high error rate (>18%) or high payment drop (>30%)

Filtering behaviour: when viewing Platform breakdown with User Type filter active, the current dimension is excluded from filters so grouping still works.

### 9. L0 Filter Bar

Chip-based filter bar between header and main content:
- Groups: User Type, Platform, Language
- Chips populated dynamically from `/api/filter-options`
- Active filters shown as removable orange pills in an amber bar below
- All charts and tables respect active filters
- "Clear All" button

### 10. Team Context Panel

Collapsible panel at the bottom of the chat sidebar:
- Add free-text context notes (product launches, known outages, campaigns, etc.)
- Notes persist in localStorage
- All notes are sent with every AI query as business context
- Purple count badge when notes are present

### 11. AI Chat Assistant

- Claude-powered NL RCA with tool-use loop (up to 8 rounds)
- Tools: get_cr_trend, get_funnel_data, get_dimension_analysis, get_failure_metrics, compare_periods
- Conversation memory per session (last 30 messages)
- RCA responses highlighted with orange left border
- Tool usage badges shown for transparency
- Suggested questions on first load

---

## CSV Data Schema

### Main File: feb_data_check2.csv

| Column | Description |
|--------|-------------|
| dt | Date (YYYY-MM-DD format) |
| user_type | guest / new / returning |
| language | en / hi / ta / te / kn / mr |
| platform | android / ios / mobile_web / web_direct / other |
| search_sessions | SRP sessions |
| oops | Sessions that hit the Oops error page (before seat layout) |
| seatlayout_sessions | Users who viewed seat layout |
| seatlayout_clicks | Seat layout click interactions |
| avg_clicks_per_session | Average seat layout clicks per session |
| seatlayout_failures | Sessions where seat layout failed to load |
| custinfo_sessions | Users who reached customer info page |
| create_order_sessions | Users who attempted tentative order creation |
| tentative_error_sessions | Sessions where tentative order failed |
| total_tentative_errors | Total tentative error count |
| orderinfo_sessions | Users who reached payment page |
| total_payment_attempts | Total payment attempts |
| total_txns | Completed transactions (bookings) |
| total_seats | Total seats booked |
| discount_txns | Transactions with discount applied |
| reddeal_txns | Transactions via RedDeal |
| GMV | Gross Merchandise Value (revenue) |
| payment_success_rate | Payment success rate |

**Date range**: Feb 1 – Mar 18, 2026 (updated with latest data)
**Key anomaly**: Error rate spikes on Feb 11–12; Mar 18 SL failure spike (10.75%)
**Transaction mix columns** (new): `discount_txns`, `reddeal_txns` → used for Discount% and RedDeal% KPIs

---

### Slices File: feb_data_check2_with_moreslices.csv

Granular session × route level data for L1 drill-downs. Customize region lists for India market maps.

| Column | Description |
|--------|-------------|
| doi | Date of interaction (YYYY-MM-DD) |
| user_type | GUEST / NEW / RETURNING |
| channel | Android / iOS / MOBILE_WEB / WEB_DIRECT / others |
| language | en / hi / ta / te / kn / mr (extend as needed) |
| dbd | Days Before Departure bucket: sameday lmb / sameday non lmb / next day / 2 days / more than 2 days |
| Region_Final | Geographic region of the route |
| Source | Source city name |
| Destination | Destination city name |
| SRP | Search sessions for this route combination |
| SL | Seat layout views |
| Cust_Info | Customer info page sessions |
| Create_Order | Create order (tentative) sessions |
| Payment_Page | Payment page sessions |
| Order_Confirmed | Confirmed orders |
| tentative_failure | Tentative failure count |
| SL_Failure | Seat layout failure count |
| seats | Seats booked |
| tin | Transaction count |
| GMV | Gross Merchandise Value |
| dis_seats | Discounted seats |
| dis_tin | Discounted transactions |

**Date range**: Feb 1 – Mar 18, 2026
**Row count**: ~2.7M (route × session × dimension combinations)
**Key note**: Counts are higher than main CSV due to data explosion (see "Data Explosion" section above)

---

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/meta` | Data date range info, anomaly period |
| `GET /api/kpis` | KPI summary for a date range |
| `GET /api/cr-trend` | Daily CR trend (optional breakdown_by dimension) |
| `GET /api/funnel` | Step-wise funnel counts |
| `GET /api/dimension/{dim}` | Per-segment breakdown for a dimension |
| `GET /api/insights` | Auto-generated statistical insights |
| `GET /api/seats` | Seats booked/lost impact analysis |
| `GET /api/period-comparison` | DoD / WoW same-day / WoW 7-day / MoM comparisons |
| `GET /api/filter-options` | Available values for L0 filter dimensions |
| `POST /api/chat` | AI RCA chat (Claude tool-use loop) |
| `DELETE /api/chat/{session_id}` | Clear conversation memory |
| `GET /api/transaction-mix` | Daily ASP + discount_pct from slices engine (optional dim/dim_val filter) |

**Common query params** (most endpoints accept these):
`start_date`, `end_date`, `filter_user_type`, `filter_platform`, `filter_language`, `filter_region`, `filter_dbd`

> **Dimension routing**: `/api/dimension/region` and `/api/dimension/dbd` are served by the slices engine (returns ASP, discount_pct, sl_failure_rate). All other dimensions use the main CSV engine.

---

## Server Setup

### Start Server

Run `START_HERE.bat` (double-click or run from terminal):
- Automatically kills port 8080 if in use
- Installs Python dependencies
- Starts uvicorn at http://127.0.0.1:8080

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_API_KEY` | Required for AI chat (get from console.anthropic.com) |
| `CSV_DATA_PATH` | Path to main aggregated CSV (`feb_data_check2.csv`) |
| `SLICES_DATA_PATH` | Path to slices CSV (`feb_data_check2_with_moreslices.csv`) — enables region/dbd drill-downs |

### Dependencies (requirements.txt)

```
fastapi, uvicorn, anthropic, pandas, numpy, python-dotenv
```

---

## Known Issues & Fixes Applied

| Issue | Fix |
|-------|-----|
| Date format DD/MM/YYYY vs YYYY-MM-DD | Auto-detect from first value in CSV |
| Numpy float64 JSON serialization error | `_clean()` helper converts numpy types to Python floats |
| NaN values in new CSV (some platforms have no funnel data) | `pd.to_numeric(..., errors='coerce')`, fillna only at aggregation |
| Platform dimension returning 404 | Added `platform` and `os` to valid dimensions set in main.py |
| Windows cp1252 encoding error (→ character) | Replaced all `→` with `to` in Python files |
| Language noise (EN uppercase, es_419, etc.) | Drop rows with language srp < 0.05% of total |
| Interface not loading | Hard refresh (Ctrl+Shift+R) or incognito mode; check browser F12 console |

---

## File Structure

```
cr-analytics/
├── START_HERE.bat          # Main startup script (port 8080)
├── start.bat               # Alternative startup script (port 8000)
├── SKILLS.md               # Product docs & feature log (this skill content)
├── backend/
│   ├── main.py             # FastAPI app, all API endpoints, Claude integration
│   ├── csv_data_engine.py  # CSV data reader & analytics engine
│   ├── mock_data.py        # Mock data engine (used when no CSV set)
│   └── requirements.txt    # Python dependencies
└── frontend/
    └── index.html          # Complete single-file frontend (HTML + CSS + JS)
```

## Cursor skill layout

```
skills/cr-analytics-assistant/
  SKILL.md                  # This file (Agent Skills standard)
```

Install: `cp -R skills/cr-analytics-assistant ~/.cursor/skills/cr-analytics-assistant`
