# Syed Athena Queries

Cursor Agent Skill: **160** saved Amazon Athena SQL queries (Product_B2C_Intl, titles ending in `- Syed`).

## Install

```bash
mkdir -p ~/.cursor/skills/syed-athena-queries
cp SKILL.md ~/.cursor/skills/syed-athena-queries/
cp -R references ~/.cursor/skills/syed-athena-queries/
```

Or clone and symlink:

```bash
git clone https://github.com/shreyanshy-del/syed-athena-queries.git
ln -sf "$(pwd)/syed-athena-queries" ~/.cursor/skills/syed-athena-queries
```

## Contents

| Path | Description |
|------|-------------|
| `SKILL.md` | Skill instructions + query index (Q001–Q160) |
| `references/*.sql` | Full SQL with Athena UUID headers |

Source: Athena workgroup `Product_B2C_Intl`. Prefer `transaction.bus_ticket_events` with `event_type = 101` and country `IND` for confirmed bus tickets.
