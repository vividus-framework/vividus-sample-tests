---
name: create-jira-issue-from-user-input
description: >-
  [QA] Turn a free-text web app scenario into a Jira Bug or Task: explore it in
  the app environment with Playwright in the browser, capture API/network/console
  evidence and screenshots, then create the issue with a full reproduction
  write-up and attachments after user approval. Scoped to web applications only
  (browser-based UI); not for mobile, desktop, or backend-only scenarios. Use
  when the user says "create issue", "log a bug", "create a task", "file a
  ticket", "create jira issue", "report a bug", or describes a web app bug/task
  scenario to be reproduced and logged.
disable-model-invocation: true
---

# Jira Issue from Scenario (Bug or Task)

## Parameters

```
SCENARIO   = "<free-text scenario from user>"
ISSUE_TYPE = "<Bug | Task — inferred or explicit>"
SEED_URL   = "<user-provided URL if given, else from references/application-context.md>"
```

**Required environment variables** (verified in Step 0 — each must be set in the
current process env, or defined in the project-root `.env`):
```
JIRA_API_EMAIL  — Atlassian account email
JIRA_API_KEY    — Atlassian API token
JIRA_CLOUD_ID   — Atlassian Cloud ID of the target Jira site
JIRA_PROJECT    — target Jira project key
JIRA_BASE_URL   — Jira site base URL (e.g. https://your-org.atlassian.net)
```

**Fixed inputs:**
```
SKILL_DIR      = "<directory that contains this SKILL.md>"   ← the folder this file was loaded from; use it for all script paths below so the skill is agent/IDE-agnostic (works under .cursor/, .github/, .claude/, …)
EVIDENCES_DIR  = "<WORKSPACE_ROOT>/.playwright-mcp/"          ← absolute path resolved in Step 0 via prepare_evidence_dir.py
```

> Always invoke the helper scripts via `<SKILL_DIR>/scripts/<name>.py`, substituting `SKILL_DIR` with the absolute path of the folder this `SKILL.md` was loaded from.

## Determine ISSUE_TYPE

1. Explicit `type=bug` or `type=task` in the user message → use that.
2. Keyword scan of `SCENARIO`:
   - **Bug**: *error, fail, broken, cannot, unable, wrong, not working, missing, incorrect, unexpected, crash, invalid, does not, doesn't, remains, inactive*
   - **Task**: *add, implement, create, write, update, refactor, investigate, improve, migrate, set up, configure, document, automate, test coverage*
3. Default → **Bug**.

---

## Step 0 — Verify Environment

Before doing anything else, verify the required Jira variables and resolve the
evidence directory.

### 0a — Required variables

Verify that every required variable is available — either in the current process
env, or in the project-root `.env`. Run the generic check script, passing the
required variable names explicitly:

```bash
python3 "<SKILL_DIR>/scripts/check_env.py" \
  --vars JIRA_API_EMAIL JIRA_API_KEY JIRA_CLOUD_ID JIRA_PROJECT JIRA_BASE_URL
```

- **Exit code 0** → all variables available; continue.
- **Exit code 1** → the script prints which variable(s) are missing. **Abort
  immediately** (do not open browser, do not generate salt) and surface the
  script's message, e.g.:
  ```
  ❌ ABORTED: required environment variables not configured.
  Missing required variable(s): <names>
  Set them in the process env or .env.
  ```
  When the missing variable is the API token, also point the user to
  https://id.atlassian.com/manage-profile/security/api-tokens

The script loads the project-root `.env` automatically and only reports variable names — it never prints their values. This step only confirms the variables **exist**.

> Credentials are held in memory only. Never written to any file.

### 0b — Resolve evidence directory

Resolve `EVIDENCES_DIR` in one step by running the helper, which ensures
`.playwright-mcp/` exists in the workspace root (creating it if needed) and
prints its absolute path:

```bash
python3 "<SKILL_DIR>/scripts/prepare_evidence_dir.py"
```

- Parse the printed `EVIDENCES_DIR=<path>` line and store `<path>` as `EVIDENCES_DIR` (it ends with a trailing `/` and uses forward slashes, so it concatenates cleanly with a filename on any OS).
- The script auto-detects the workspace root and is cross-platform (standard library only). On Windows, if `python3` is not on `PATH`, use `python` instead.

---

## Step 1 — Application Context

Load the application context before opening the browser, following
[references/application-context.md](references/application-context.md), which
describes the context sources to read and the rules for using them.

---

## Checkpoints — Confirm with user before proceeding

Run all three checkpoints in sequence. **Wait for user reply after each one before moving to the next.**

---

### Checkpoint 1 — Related Jira ticket?

Ask the user:
```
🔗 Checkpoint 1 — Related Jira ticket

Is this issue related to an existing Jira ticket (story, bug, or task)?
  yes <PROJECT-KEY-NNN>  →  I'll fetch its description for additional requirements/AC
  no                     →  I'll rely on application context + app knowledge only
```

- **yes `<key>`** → call `getJiraIssue(cloudId, issueIdOrKey=<key>, responseContentFormat="markdown")` and extract requirements, AC, and in-scope notes. Store as `RELATED_TICKET`. Use this to sharpen step-by-step reproduction and expected results.
- **no** → set `RELATED_TICKET = null`. Proceed with application-context knowledge.

---

### Checkpoint 2 — Reuse existing test data?

Ask the user:
```
🗂️ Checkpoint 2 — Test data

Should I reuse existing test data, or create fresh records?
  reuse  →  tell me the identifiers of the records to reuse
  new    →  I'll generate fresh test data from scratch
```

Resolve the answer (`reuse` → `EXISTING_DATA`, `new` → generate) per
[references/test-data-rules.md](references/test-data-rules.md), which is the
single source of truth for when to reuse vs. generate.

---

### Checkpoint 3 — Check level

Ask the user:
```
🔬 Checkpoint 3 — Check level

How deep should the investigation go? (select one or more)

  1. UI only          — screenshots of visible state; no network or console capture
  2. UI + Network     — screenshots + API request/response for the key action
  3. UI + Console     — screenshots + browser JS errors/warnings
  4. UI + Network + Console  — full frontend evidence (recommended for complex bugs)

Default: 2 (UI + Network)
```

Store the confirmed level(s) as `CHECK_LEVEL`. Apply in Step 3:

| Level selected | What to capture in Step 3 |
|---|---|
| UI only | Full-page screenshot only |
| + Network | Also capture: endpoint, method, request body, response status + body via `browser_network_requests` |
| + Console | Also capture: JS errors/warnings via `browser_console_messages` |

---

## Step 2 — Prepare Test Data

> Skip if Checkpoint 2 answer was **reuse** for all needed entities.

Follow [references/test-data-rules.md](references/test-data-rules.md) for the
complete test-data rules: when to generate vs. reuse, the generation procedure,
naming conventions, the reuse exception, and what counts as a "new record".
Store the resulting `SALT` and derived values for use in Step 3.

---

## Step 3 — Explore Scenario in Browser

> Skip browser exploration for Tasks where it is not applicable.

`EVIDENCES_DIR` is already resolved in Step 0b — use that value for all
screenshot paths below.

Before capturing, derive a **working** `SUMMARY_SLUG` for filenames from
`SCENARIO` (and `RELATED_TICKET` if set) — lowercase, spaces → hyphens, strip
special chars, max 50 chars. This is only a filename helper; it does **not** need
to match the final issue summary produced in Step 5.

1. Navigate to `SEED_URL` (authentication per [references/application-context.md](references/application-context.md)).
2. Follow the steps implied by `SCENARIO` using the application context as a guide. If `RELATED_TICKET` is set, use its AC/requirements to sharpen the reproduction steps.
3. Use `EXISTING_DATA` identifiers (Checkpoint 2 = reuse) or generated values (Checkpoint 2 = new), creating fresh records per [references/test-data-rules.md](references/test-data-rules.md). **Always create new records when reuse was not approved.**
4. Perform the key action that `SCENARIO` is about (e.g. submit / save / create / delete).
5. Fill every form field with the prepared test-data values.
6. Capture evidence according to `CHECK_LEVEL` (Checkpoint 3). Capture a screenshot at **every** state that helps prove the issue — not just one. Typical moments: the setup/precondition state, immediately **before** the key action, the **after**/result state, and any **error** state. Collect all filenames into a `SCREENSHOTS` list.
   - **Always:** Build each screenshot filename as `<SUMMARY_SLUG>-<state>-<SALT>.png`, using the working `SUMMARY_SLUG` derived above. `<state>` is a short descriptor (e.g. `before`, `after`, `error`); omit the `-<state>` segment when only one screenshot is meaningful. Example: `field-resets-after-save-before-84aed1ae.png`. Call `browser_take_screenshot` with `fullPage: true` and `filename: "<EVIDENCES_DIR><filename>"` — the filename already ends in `.png`, so do **not** append another extension. Append the resulting absolute path to `SCREENSHOTS`.
   - **+ Network:** Call `browser_network_requests` — record endpoint, method, request body, response status + body.
   - **+ Console:** Call `browser_console_messages` — record JS errors and warnings.
7. Document what happened (success / error message / UX issues), noting which screenshot in `SCREENSHOTS` evidences each point.

**Abort if** environment is unreachable:
```
❌ ABORTED: Cannot explore scenario.
Reason: <specific reason>
```

---

## Step 4 — Analyse

### Bug
| Result | Action |
|---|---|
| 🐛 Bug / partial bug | Continue to Step 5 |
| ✅ No bug | Stop — report success, do not create issue |

### Task
Skip classification. Summarise scope, then continue to Step 5.

---

## Step 5 — Create Jira Issue

Build the description in Markdown using the appropriate template:
- Bug → [references/bug-template.md](references/bug-template.md)
- Task → [references/task-template.md](references/task-template.md)

First read the **connection values** needed for `createJiraIssue`:

```bash
python3 "<SKILL_DIR>/scripts/check_env.py" \
  --print --vars JIRA_CLOUD_ID JIRA_PROJECT JIRA_BASE_URL
```

Use the `KEY=VALUE` lines from stdout and store `JIRA_CLOUD_ID`,
`JIRA_PROJECT`, `JIRA_BASE_URL`.

> **Never** `--print` the secret variables (`JIRA_API_KEY`, `JIRA_API_EMAIL`).

Then resolve the per-ticket field config (issue types, labels, components,
custom fields, priority, summary convention, description format) from
[references/jira-ticket-settings.md](references/jira-ticket-settings.md).

**Before calling `createJiraIssue`, present a preview to the user and ask for approval:**

```
📋 Ready to create Jira <Bug | Task>:

Type:        <Bug | Task>
Summary:     <proposed summary>
Priority:    <High | Medium | Low>
Labels:      <labels per jira-ticket-settings.md>
Description preview:
---
<first ~20 lines of the markdown description>
...
---

Shall I create this issue? (yes / no / edit)
```

- **yes** → proceed with `createJiraIssue`
- **no** → abort; output `❌ Issue creation cancelled by user.`
- **edit** → ask what to change, update the draft, then re-present the preview

Then call `createJiraIssue` using the env vars for connection and
[references/jira-ticket-settings.md](references/jira-ticket-settings.md) for the
fields:
```
createJiraIssue(
  cloudId:       <JIRA_CLOUD_ID>,
  projectKey:    <JIRA_PROJECT>,
  issueTypeName: "<Bug | Task>",
  summary:       "<summary per convention>",
  description:   "<markdown description>",
  contentFormat: "markdown",
  additional_fields: <labels + custom fields + priority per jira-ticket-settings.md>
)
```

Store the returned `key` as `NEW_ISSUE_KEY`.

---

## Step 6 — Attach Screenshots

Attach **every** file collected in `SCREENSHOTS` (Step 3). All paths in
`SCREENSHOTS` are absolute (resolved in Step 3). Pass them all in a single
`--file` argument — the script uploads each and reports per-file success:

```bash
python3 "<SKILL_DIR>/scripts/upload_attachment.py" \
  --issue NEW_ISSUE_KEY \
  --file <absolute-path-1> <absolute-path-2> ...
```

Skip for Tasks that produced no screenshots. If some uploads fail, warn (listing
the failed files) but do not abort — the issue is already created.

---

## Step 7 — Output

```
✅ Jira <ISSUE_TYPE> created successfully.

Key:        <NEW_ISSUE_KEY>
Type:       <Bug | Task>
Title:      <summary>
URL:        <JIRA_BASE_URL>/browse/<NEW_ISSUE_KEY>
Screenshots: <N attached ✅ — list filenames>  (or N/A)
Scenario:   "<SCENARIO>"
Salt:       <SALT>
Test data:  <relevant salted fields>
```

---

## Abort Conditions

| Condition | Action |
|---|---|
| Credentials missing | ❌ Stop — do not open browser |
| User cancels at any Checkpoint | ❌ Stop — output "Cancelled at Checkpoint N." |
| Browser auth fails | ❌ Stop |
| Page / URL not found | ❌ Stop |
| Network not captured | ⚠️ Continue — UI evidence only, skip API section |
| No bug found (Bug type) | ✅ Stop — do not create issue |
| User declines approval | ❌ Stop — output "Issue creation cancelled by user." |
| `createJiraIssue` fails | ❌ Stop |
| Some/all screenshot uploads fail | ⚠️ Issue created — list failed files, attach them manually |
