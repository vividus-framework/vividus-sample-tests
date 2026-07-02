# create-jira-issue-from-user-input

An agent skill that turns a free-text scenario into a well-formed Jira
**Bug** or **Task**. The agent reproduces the scenario in a live (dev) browser
session with Playwright, captures evidence (screenshots, network, console), and
— after explicit user approval — files the issue with a full write-up and
attaches the screenshot.

The agent-facing runbook is [`SKILL.md`](SKILL.md). This README is the
human-facing overview for adopting the skill in your own project.

## Prerequisites

- **Playwright MCP** server — for browser navigation and evidence capture
  (`browser_take_screenshot`, `browser_network_requests`, `browser_console_messages`).
- **A Jira MCP** exposing `createJiraIssue` and `getJiraIssue` (e.g. the
  Atlassian MCP).
- **Python 3** — standard library only; no `pip install`.

## Configuration

### Environment variables (required)

All five variables below are **required**. Each must be set **either** in the
current process environment **or** in a `.env` file in the project root (process
env takes precedence). If any is missing from both, the skill aborts at Step 0.

| Variable | Purpose |
|---|---|
| `JIRA_API_EMAIL` | Atlassian account email |
| `JIRA_API_KEY` | Atlassian API token ([create one](https://id.atlassian.com/manage-profile/security/api-tokens)) |
| `JIRA_CLOUD_ID` | Atlassian Cloud ID of the target site |
| `JIRA_PROJECT` | Target Jira project key |
| `JIRA_BASE_URL` | Jira site base URL, e.g. `https://your-org.atlassian.net` |

Step 0 of the skill verifies all five are available (process env or `.env`)
before any browser action; if any is missing it aborts and names the missing
variable(s).

### Project-specific references (edit these for your app)

All project specifics live in [`references/`](references/) so `SKILL.md` stays
generic. To adopt the skill for your own app, work through these files in order:

1. **[`application-context.md`](references/application-context.md)** — set the
   entry-point URL (`SEED_URL`), describe your sign-in/authentication flow, and
   list the navigation context sources (sitemaps, docs) the agent should read
   before exploring.
2. **[`jira-ticket-settings.md`](references/jira-ticket-settings.md)** — set the
   issue types, labels, components, custom fields, priority mapping, and the
   summary convention used when the issue is created.
3. **[`bug-template.md`](references/bug-template.md)** and
   **[`task-template.md`](references/task-template.md)** — adjust the Markdown
   description templates (sections, headings, wording) to match how your team
   writes bugs and tasks.
4. **[`test-data-rules.md`](references/test-data-rules.md)** — define when to
   reuse vs. generate test data, the naming conventions for generated records,
   and any reuse exceptions specific to your app.

## Usage

Trigger it in chat by describing a scenario, for example:

- "create a jira issue: the shipping address field goes blank after I click Save on checkout"
- "log a bug — applying promo code SUMMER25 gives a 15% discount instead of 25%"
- "report a bug: clicking 'Export to CSV' on the orders page just spins forever and never downloads"
- "file a task to add email-format validation on the sign-up form"

Any phrasing like "create issue", "log a bug", "create a task", "file a ticket",
or a described bug/task scenario will trigger the skill.

The agent runs three confirmation checkpoints (related ticket, test data,
investigation depth), then previews the issue and waits for your approval before
creating anything.

## Layout

```
create-jira-issue-from-user-input/
├── SKILL.md                 # agent runbook (steps + checkpoints)
├── README.md                # this file
├── references/              # project-specific config & templates
└── scripts/                 # Python helpers used by the skill
```
