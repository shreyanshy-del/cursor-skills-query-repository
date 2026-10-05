# Skills_CR

Catalog of **CR Analytics** Cursor skills. Core conversion/funnel contracts live in `cr-analyser`; dimensions and domain packs attach onto the same `mri_session_id` grain.

**Package home (interim):** `cursor-skills-query-repository` → `skills/`  
**Local:** `/home/ubuntu/cr-analytics/skills/`  
**Install:** `scripts/install-cursor-skills.sh`

---

## Core

| Skill | Path | What it does |
|---|---|---|
| `cr-analyser` | `skills/cr-analyser/` | India BUS CR = TIN/SRP; ordered throughput SRP→SL→CI→TCO→PAY→PAY_NOW→CONFIRM; product identity ∏ steps = CR |

**Fixed contracts**

| # | Step | Formula |
|---|---|---|
| 1 | SRP → SL | SL / SRP |
| 2 | SL → CI | CI / SL |
| 3 | CI → TCO | TCO / CI |
| 4 | TCO → PAY | PAY / TCO |
| 5 | PAY → PAY_NOW | PAY_NOW / PAY |
| 6 | PAY_NOW → CONFIRM | TIN / PAY_NOW |
| 7 | CR | TIN / SRP |

- SRP: distinct `mri_session_id` from `user_interaction.search_details`
- Joins: `mri_session_id` only
- TIN: `transaction.bus_ticket_events` (`event_type = 101`, `event_class = 2`, `country_code = 'IND'`)

---

## Dimension skills (first set)

Use with `cr-analyser`. Recompute step rates **inside each cut**; product identity must still hold.

| Skill | Cut | Source |
|---|---|---|
| `cr-dim-usertype` | Usertype (GUEST / NEW / RETURNING) | `search_details.user_type` |
| `cr-dim-dbd` | DBD (0,1,2,3,4,5+) | `search_details` DOI vs `doj` |
| `cr-dim-lmb` | LMB / Non-LMB | `search_details` DBD 0 only; IST hour 17–23 = LMB |
| `cr-dim-channel` | Android / iOS / Web / Mobweb | `search_details.os` + `channel` |
| `cr-dim-region-tier` | Region / State | `lis.config_locations.parent_location` on src/dest |
| `cr-dim-sd-type` | Short / Long | `lis.short_route_sds` → Short else Long |
| `cr-dim-custom-sd` | Custom SD | `search_route_details` + **input** SD list |
| `cr-dim-ga-plugin` | GA Plugin | `ui_ux_events` — **input** `event_group` / `event_name` / `event_value` |
| `cr-dim-operator` | Operator_ID | `search_route_details.op_id` |
| `cr-dim-bo-type` | RTC / PRIVATE / PRIMO | `lis.bo_mappings.is_rtc`; BTE `hft=2`; else PRIVATE |
| `cr-dim-age-gender` | Age / Gender | `svoc.svoc_booker` via `rb_user_id` |
| `cr-dim-bus-type` | AC / Sleeper / Seater / Hybrid | `search_route_details.is_ac`, `is_sleeper`, `is_seater` |

---

## redBus analytics skills

| Skill | Covers |
|---|---|
| `women-funnel-analytics` | Women SRP vs Regular vs Female/Male SVOC, QoQ funnel, single-women DOJ, 14-day return |
| `return-tier-pilgrim` | Mehar city tiers, onward-booker return funnel, pilgrim high/low, UPSRTC |
| `lmb-newbus-analytics` | DBD-0 LMB vs rest-of-day, New Bus (persuasion 68), unfiltered SRP rank shares |
| `experiment-coverage-analytics` | Insurance Lite AB, iOS addons payment-page AB, Primo operators, Mobweb login/signup |
| `toilet-cohort-analytics` | Toilet-on-SL vs amenity vs India, pre/post Aug 2026 (OMS) |
| `seat-bus-images` | Seat-utility image CTR, NewBusImageLoaded coverage, route txn share |
| `metro-surface-analytics` | Metro Home, Card, and Sticky on bus buddy after a metro ticket |
| `filter-usage-analytics` | Filter canvas / Sort / Contextual / LMB / Inline usage |
| `syed-athena-queries` | Syed Athena query bank |
| `query-repository` | Shared SQL query bank |

---

## How to pick a skill

1. **Overall India CR / funnel throughput** → `cr-analyser`
2. **Same CR cut by a dimension** → `cr-analyser` + matching `cr-dim-*`
3. **Domain deep-dive** (women, pilgrim, LMB, AB, toilet, images, metro, filters) → matching analytics skill
4. **Known SQL from bank** → `query-repository` or `syed-athena-queries`

---

## Related docs

- `CR-ANALYTICS.md` — package overview
- `/cursor/stores/self/docs/cr-dimensions-query-map.md` — dimension → table map
- `/cursor/stores/self/docs/project-context.md` — project wiring
- `/cursor/stores/self/docs/team-brief.md` — team socialization brief
