# Bug Description Template

Use this template when `ISSUE_TYPE = Bug`. Fill the angle-bracket placeholders
with scenario-specific details captured while exploring the scenario.

```markdown
## Summary
<One sentence: what is broken and where. Include feature/page name.>

---

## Environment
- **App / Area:** <app name and the page or feature, e.g. "Customer Portal — Checkout">
- **URL:** <exact URL where bug was found>
- **Environment:** <Dev | Staging | Prod>
- **Date found:** <YYYY-MM-DD>

---

## Steps to Reproduce
1. <Step derived from SCENARIO — be explicit>
2. <...>
N. <Perform the key action>

---

## Expected Result
<What should happen>

---

## Actual Result
- <Exact error message shown in UI if any>
- <Other broken behaviour>

📎 Screenshots attached (one line per file; describe what each shows):
- `<screenshot-1-filename>` — <what this screenshot shows, e.g. state before action>
- `<screenshot-2-filename>` — <what this screenshot shows, e.g. state after action / error>

---

## API / Network Evidence

### Request
```
<METHOD> <endpoint>
Content-Type: application/json

<request body JSON>
```

### Response — <status code> <status text>
```json
<full response body>
```

---

## Root Cause Analysis
<If identifiable: which fields/components/API contract mismatch caused the failure.>

| Control / Field | <behaviour under test> |
|---|---|
| `<fieldName>` | ✅ / ❌ |

---

## Additional Issues Observed
<Secondary UX bugs: misleading errors, missing field indicators, disabled buttons, silent data loss, etc.>
```
