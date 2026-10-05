# CR Analytics


**Skill catalog:** [`Skills_CR.md`](Skills_CR.md)
**Display name:** CR Analytics  
**Cursor skill (core):** `cr-analyser` (CR Analyser)

India BUS conversion and funnel analytics package: core CR contracts, dimension cuts, and redBus domain analytics skills.

## Layout

```
skills/
  cr-analyser/                 # Core CR = TIN/SRP + ordered funnel
  cr-dim-*/                    # First dimension cuts
  women-funnel-analytics/
  return-tier-pilgrim/
  lmb-newbus-analytics/
  experiment-coverage-analytics/
  toilet-cohort-analytics/
  seat-bus-images/
  metro-surface-analytics/
  filter-usage-analytics/
  syed-athena-queries/
  query-repository/
```

## Core contracts (fixed)

| # | Step | Formula |
|---|---|---|
| 1 | SRP → SL | SL / SRP |
| 2 | SL → CI | CI / SL |
| 3 | CI → TCO | TCO / CI |
| 4 | TCO → PAY | PAY / TCO |
| 5 | PAY → PAY_NOW | PAY_NOW / PAY |
| 6 | PAY_NOW → CONFIRM | TIN / PAY_NOW |
| 7 | CR | TIN / SRP |

Identity: **CR = (1)×(2)×(3)×(4)×(5)×(6)**. If that fails, the analysis is in error.

- SRP sessions: `user_interaction.search_details` (`mri_session_id`)
- Joins: `mri_session_id` only (no channel cut by default)
- TIN: `transaction.bus_ticket_events`, `event_type = 101`, `event_class = 2`
- Country: IND

## Dimension skills (first set)

| Skill | Cut | Source |
|---|---|---|
| `cr-dim-usertype` | Usertype | `search_details.user_type` |
| `cr-dim-dbd` | DBD | `search_details` DOI vs doj |
| `cr-dim-lmb` | LMB / Non-LMB | `search_details` DBD0 IST hour 17–23 |
| `cr-dim-channel` | Channel | `search_details.os` + `channel` |
| `cr-dim-region-tier` | Region / State | `lis.config_locations.parent_location` on src/dest |
| `cr-dim-sd-type` | Short / Long | `lis.short_route_sds` else Long |
| `cr-dim-custom-sd` | Custom SD | `search_route_details` + input SD list |
| `cr-dim-ga-plugin` | GA Plugin | `ui_ux_events` (user inputs group/name/value) |
| `cr-dim-operator` | Operator_ID | `search_route_details.op_id` |
| `cr-dim-bo-type` | BO Type | `lis.bo_mappings.is_rtc` / BTE `hft=2` / PRIVATE |
| `cr-dim-age-gender` | Age / Gender | `svoc.svoc_booker` via `rb_user_id` |
| `cr-dim-bus-type` | AC / Sleeper / Seater | `search_route_details.is_ac/is_sleeper/is_seater` |

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

## Install

```bash
# Core
cp -R skills/cr-analyser ~/.cursor/skills/cr-analyser
cp -R skills/cr-dim-* ~/.cursor/skills/

# Domain analytics
for s in women-funnel-analytics return-tier-pilgrim lmb-newbus-analytics \
         experiment-coverage-analytics toilet-cohort-analytics seat-bus-images \
         metro-surface-analytics filter-usage-analytics syed-athena-queries \
         query-repository; do
  cp -R "skills/$s" ~/.cursor/skills/"$s"
done

# or: scripts/install-cursor-skills.sh
```

## Publish

```bash
gh skill publish --tag v1.0.0
```

Change only the date window in reference SQL the user asks for.

## Assistant product skill

| Skill | Covers |
|---|---|
| `cr-analytics-assistant` | India CR Analytics Assistant — RCA decision tree, causation vs correlation, shopper-spike hierarchy, feature log, CSV schemas, APIs |

Also mirrored as package-root `SKILLS.md`.


## CR Analyser app (dashboard)

India CR Analytics Assistant — FastAPI + single-file frontend.

```bash
cd /home/ubuntu/cr-analytics
./START_HERE.sh
# open http://127.0.0.1:8080
```

| Path | Role |
|---|---|
| `backend/main.py` | APIs + RCA chat |
| `backend/csv_data_engine.py` | KPIs, funnel, dimensions, mix-shift RCA |
| `backend/mock_data.py` | Auto sample CSVs when none configured |
| `frontend/index.html` | Dashboard UI |
| `SKILLS.md` / `skills/cr-analytics-assistant` | Product skills & feature log |
| `skills/cr-analyser` | Iceberg SQL CR contracts |

Optional env: `CSV_DATA_PATH`, `SLICES_DATA_PATH`, `ANTHROPIC_API_KEY`.


## Dashboard (this repo)

```bash
./START_HERE.sh
# http://127.0.0.1:8080
```

Canonical GitHub for this package is **this repository** (`cursor-skills-query-repository`), not `CR-Analytics`.

## Mac (simplest)

Double-click [`CR_Analyser.html`](CR_Analyser.html). See [`OPEN_ON_MAC.md`](OPEN_ON_MAC.md).
