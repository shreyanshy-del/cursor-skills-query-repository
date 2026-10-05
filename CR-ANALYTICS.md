# CR Analytics

**Display name:** CR Analytics  
**Cursor skill:** `cr-analyser` (CR Analyser)

India BUS conversion skill for the CR Analyser dashboard: **CR = TIN / SRP**, with ordered funnel throughput and a hard product identity.

## Layout

```
skills/cr-analyser/
  SKILL.md
  references/cr_analyser_1d.sql
```

## Contracts (fixed)

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

## Install

```bash
gh skill install shreyanshy-del/cr-analytics cr-analyser
# or
cp -R skills/cr-analyser ~/.cursor/skills/cr-analyser
```

## Publish

```bash
gh skill publish --tag v1.0.0
```

Change only the date window in `references/cr_analyser_1d.sql`.


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

Install: `cp -R skills/cr-dim-* ~/.cursor/skills/` or `gh skill install shreyanshy-del/cursor-skills-query-repository <skill>`.
