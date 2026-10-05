# Canvas structure — Filter Usage (Android & iOS)

File: `~/.cursor/projects/<workspace>/canvases/filter-usage-android.canvas.tsx`

## Dropdowns

- **Sheet** — switches sections below
- **Platform** — `ALL` | `Android` | `iOS`
- **User type** — `ALL` | `RETURNING` | `NEW` | `GUEST`

## Sheets (order)

1. **Overall filter** — any applied / SRP load (default first slide)
2. **Usage overview** — Sort vs SRP + LMB/Inline/Contextual snapshot + excluded-version callout
3. **Sort & Filter** — usage table → top `event_value` → top `filter_applied`
4. **Contextual** — Clicked / SRP + chips (AC, SLEEPER, Primo Bus, Deals, …)
5. **LMB** — Viewed/Clicked coverage by usertype
6. **Inline** — coverage + RTC bus-type chips (SUPER LUXURY, VOLVO, JANRATH, …)
7. **AI** — callout when no events
8. **Screenshot** — daily volume; note null page/usertype

## Implementation rules

- Import only from `cursor/canvas`
- Embed all data inline (no network)
- Prefer Σ of daily distinct for multi-day coverage %
- Call out eligible app versions and excluded inflators (e.g. Android 82.2.51)
