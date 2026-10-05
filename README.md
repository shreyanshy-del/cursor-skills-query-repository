# Cursor Skills — Query Repository + CR Analytics

**CR Analytics** (skill `cr-analyser`) lives here until a dedicated `shreyanshy-del/cr-analytics` repo can be created (Cloud Agent GitHub App cannot create repos). See [CR-ANALYTICS.md](CR-ANALYTICS.md).


Personal redBus SQL query bank as a Cursor Agent Skill (**70 queries**).

## Layout

```
skills/cr-analyser/          # CR Analytics / CR Analyser
skills/query-repository/
  SKILL.md
  references/*.sql
  references/samples/live-pulls.md
```

## Install in Cursor

Copy or symlink into:

- Project: `.cursor/skills/query-repository`
- Personal: `~/.cursor/skills/query-repository`

## Publish (gh skill, preview)

```bash
gh skill publish --tag v1.0.0
```

Totals: 70 queries | Live DB pulls: 9 | Default country: IND
