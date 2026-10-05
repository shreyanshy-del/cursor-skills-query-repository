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
