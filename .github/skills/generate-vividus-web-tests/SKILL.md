---
name: generate-vividus-web-tests
description: 'Generate VIVIDUS test automation stories from test cases for web applications. Creates executable .story files following VIVIDUS syntax and project conventions. Use when: automating web test cases, converting manual tests to VIVIDUS stories, generating web UI test automation.'
argument-hint: 'Enter your test case...'
---

## Process Overview

1. **Retrieve** test cases to automate
2. **Execute** test cases with Playwright
3. **Analyze** test case coverage
4. **Explore** VIVIDUS story writing guidelines
5. **Generate** VIVIDUS stories

---

## Step 1: Retrieve test cases

Extract test case(s) from the user's prompt input.

Each test case **must** contain:
- **Test Steps**: Numbered, sequential actions to perform
- **Expected Results**: Clear, verifiable outcomes for each step or the entire test

**ABORT** further execution if:
- Test steps are missing or not provided
- Expected results are not defined
- Input does not represent a valid test case structure

When aborting, explain what is missing and request a complete test case.

---

## Step 2: Execute test cases

Use Playwright MCP to execute test cases and collect element locators for VIVIDUS story generation in Step 4.

## No-Playwright = User Decision Policy

If Playwright execution is unavailable (browser backend closed, MCP disconnected, navigation failed), the skill must not claim live validation or silently use inferred locators.

### Required Behavior

Inform the user that live UI discovery and validation cannot be performed, then offer:
1. **Retry later** after Playwright/MCP is restored (**recommended**)
2. **Continue with known locators** marked as **unverified**


### Execution process

1. **Navigate**: `browser_navigate(url)` - URL from test case or user prompt

2. **For each test step**:
   - **DO NOT take screenshots**, use `browser_snapshot()` to take a page snapshot to understand page structure and its elements
   - Identify key elements from test cases e.g. form fields, interactive elements, visual components etc. and document their refs, text content and labels, states
   - Collect stable locator attributes: IDs, data-testid, aria-labels, exact button/link text
   - Perform actions to verify element behaviors: `browser_click`, `browser_type`, `browser_select_option`, or `browser_run_code`
   - Document any differences from expected results or any missing or changed elements

3. **Dynamic content**: `browser_wait_for(text)` for async operations

### Assumption Handling

When encountering unclear steps in test cases, or when blocked the agent should:
1. Proceed with reasonable assumption or workaround
2. Document assumption or workaround clearly


### When to STOP and Ask (Do NOT Assume)

Do **NOT** proceed with assumptions in these situations. Stop execution and request clarification:

| Situation | Why Ask |
|-----------|---------|
| Authentication credentials required but not provided | Security-sensitive, cannot guess |
| Target environment URL missing or unclear | Wrong environment could cause data issues |
| Test references external dependencies (APIs, databases) not accessible | Cannot verify integration behavior |
| Expected result describes business logic that cannot be verified visually | Requires domain knowledge |
| Test case references another TC ("See TC-XXX") that is not provided | Missing context for complete execution |
| Multiple valid interpretations exist with significantly different outcomes | Assumption could invalidate entire test |

---

## Step 3: Analyze Coverage & Map to VIVIDUS

### Logic & Flow Planning
**Before choosing any steps**, write out the logical flow of the test to ensure it makes functional sense.
1. Identify the *high-level* actions (e.g., "Login", "Navigate to User Profile", "Change Password").
2. Ensure the sequence handles state changes (e.g., "Page must be reloaded after saving" or "Modal must be closed").
3. Check for specific negative scenarios: Ensure the test verifies the *fail state* (e.g., "Error message visible") and doesn't accidentally succeed if the error is missing.

### Discovery & Marking
VIVIDUS capabilities and project discovery:
1. **MUST** fetch available VIVIDUS steps by calling the MCP tool matching pattern `vividus_get_all_features`
   - **ABORT** if the VIVIDUS MCP tool is not available or not connected. Instruct the user to connect the VIVIDUS MCP server before proceeding. Without this tool, valid steps cannot be discovered and stories will contain incorrect syntax.
2. Read existing resources to learn patterns and conventions:
    - `src/main/resources/story/**/*.story` — existing stories
    - `src/main/resources/steps/*.steps` — reusable composite steps
3. Lifecycle and Examples usage (transformers, data tables), scenario structure and naming, meta tags

⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

**Strict** rules to adhere:
1. **ONLY use steps returned by the MCP tool matching pattern `vividus_get_all_features`** — NEVER invent, modify, or assume steps that are not explicitly listed
2. **Preserve exact syntax** - do not modify step parameters or structure
3. **Use exact locator strategies**: `cssSelector`, `xpath`, `id`, `caseInsensitiveText`, `name`
4. **If a required step is NOT available** - DO NOT silently ignore, mark as `[MISSING STEP]`


## Step 4: VIVIDUS Story Guidelines

### General rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **Locators:** Follow the **Strict Hierarchy** below to ensure stability.
3. **Data Tables:** Use Examples blocks for parameterized scenarios
4. **Composite Steps:** Reuse existing composite steps; propose new ones for repeated patterns
5. **Contextual Steps:** When using parent element context, ensure child locators are relative
6. **No step-by-step comments:** Do NOT add `!--` comments before each step describing what it does (e.g., `!-- Step 1: Log in`). Only use `!--` comments for `[MISSING STEP]`, `[ASSUMPTION]`, or `[DISCREPANCY]` markers.

### Locator Stability Hierarchy
When identifying elements, you **MUST** prefer locators in this order:

1.  🥇 **Exquisite**: `data-testid`, `data-test`, `data-qa`
2.  🥈 **High**: `id` (ONLY if it looks human-readable and stable, e.g., `#submit-btn`. REJECT auto-generated IDs like `#ember123`)
3.  🥉 **Medium**: `buttonName()` or `linkText()` (Semantic and readable)
4.  ⚠️ **Low**: `caseInsensitiveText()` or `formName/fieldName` (Use with caution for localization)
5.  ⛔ **Last Resort**: `cssSelector` or `xpath` (Only if NO other option exists. XPath must be robust, avoiding indexing like `div[3]/span[2]`)

### Avoid Redundant Verifications

Do NOT verify the same element/text twice. If you wait for an element, it's already verified.

❌ **Bad** - redundant check:
```gherkin
When I wait until element located by `caseInsensitiveText(My Account)` appears
Then text `My Account` exists
```

✅ **Good** - single verification:
```gherkin
When I wait until element located by `caseInsensitiveText(My Account)` appears
```
### Verify text using text assertion steps

Verify the text using text assertion steps:
```gherkin
Then text `<expected-text>` exists
```

The `Then text` step accepts **plain text only** — do NOT wrap it in `caseSensitiveText()` or `caseInsensitiveText()`. Those are **locator filters** and only work in locator-based steps (e.g., `When I click on element located by`).

❌ **Bad** — locator filter in a text step:
```gherkin
Then text `caseSensitiveText(Sauce Labs Bolt T-Shirt)` exists
```

✅ **Good** — plain text:
```gherkin
Then text `Sauce Labs Bolt T-Shirt` exists
```

### Where `caseSensitiveText()` / `caseInsensitiveText()` ARE valid

Use them **only** in locator-based steps:
```gherkin
When I click on element located by `caseSensitiveText(Save)`
When I wait until element located by `caseInsensitiveText(My Account)` appears
Then number of elements found by `caseInsensitiveText(Submit)` is equal to `1`
```

Text comparison strategy for **locator-based steps**:

Default: use `caseSensitiveText(..)` when the text is part of the UI specification (labels, buttons, headers, brand names, statuses, fixed UI wording).

Use `caseInsensitiveText(..)` only when case is not relevant and the text is dynamic or content-driven.

Typical cases for `caseInsensitiveText(..)`:
- Search results / dynamically generated lists
- CMS-driven or backend-provided content
- Notifications / informational messages where formatting may vary
- API-driven or external system data
- Cases where UI text is not strictly defined by design specifications

### Verify Page by URL (Mandatory)

When a test case step says "Verify <Page> page is displayed/loaded/opened", you **MUST** validate the page by checking the current page URL using `${current-page-url}`. Do **NOT** verify the page by checking text or elements on the page.

✅ **Good** - URL validation:
```gherkin
Then `${current-page-url}` matches `.+/inventory\.html`
```

```gherkin
Then `${current-page-url}` matches `.+/inventory-item\.html\?id=1`
```

❌ **Bad** - text/element-based page verification:
```gherkin
Then text `Products` exists
```

```gherkin
When I wait until element located by `caseInsensitiveText(Your Cart)` appears
```

**Rules:**
1. Always use ``Then `${current-page-url}` matches `<regex>` `` to verify the correct page is displayed
2. The regex should match the distinctive part of the URL path (e.g., `/cart\.html`, `/inventory-item\.html`)
3. Never use text assertions or element waits as a substitute for page verification

## Step 5: Generate VIVIDUS story

### Prefer buttonName Locator for Buttons

When interacting with button HTML elements, use `buttonName` locator instead of xpath.

❌ **Bad** - verbose xpath:
```gherkin
When I click on element located by `xpath(//button[contains(text(),'Save')])`
```

✅ **Good** - clean buttonName locator:
```gherkin
When I click on element located by `buttonName(Save)`
```

### Synchronize After Page Navigation

**CRITICAL RULE**: After navigating to a new page, synchronize using `When I wait until element located by \`<page-unique-element>\` appears` followed by a URL check with `Then \`${current-page-url}\` matches \`<regex>\``.

A "new page load" occurs when:
- A navigation link is clicked that loads a different URL
- A button click opens a new tab or modal
- A form submission redirects to a different page

**Synchronization method** — after every navigation action use this two-step pattern:
1. `When I wait until element located by \`<first-unique-element-on-target-page>\` appears` — waits for the new page to render
2. `Then \`${current-page-url}\` matches \`<regex>\`` — confirms the correct page loaded

The wait step picks a **single element unique to the target page** (e.g., a page heading, a key form field, or a data-test marker). The URL check confirms the navigation landed on the expected route.

If the target URL is not descriptive (e.g., dynamic hash-only routes), the wait step alone is sufficient.

✅ **Good** - wait + URL check after navigation:
```gherkin
When I click on element located by `cssSelector([data-test="item-1-title-link"])`
When I wait until element located by `id(back-to-products)` appears
Then `${current-page-url}` matches `.+/inventory-item\.html\?id=1`
When I click on element located by `id(add-to-cart)`
```

✅ **Good** - wait + URL check after opening cart:
```gherkin
When I click on element located by `cssSelector([data-test="shopping-cart-link"])`
When I wait until element located by `cssSelector([data-test="cart-list"])` appears
Then `${current-page-url}` matches `.+/cart\.html`
Then text `Sauce Labs Bolt T-Shirt` exists
```

❌ **Bad** - URL check only, no wait (page may not be fully rendered):
```gherkin
When I click on element located by `cssSelector([data-test="item-1-title-link"])`
Then `${current-page-url}` matches `.+/inventory-item\.html\?id=1`
```

❌ **Bad** - wait only, no URL check (doesn't confirm correct page):
```gherkin
When I click on element located by `cssSelector([data-test="item-1-title-link"])`
When I wait until element located by `id(back-to-products)` appears
```

❌ **Bad** - no synchronization after navigation:
```gherkin
When I click on element located by `buttonName(Add Product)`
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
```

❌ **Bad** - wait before every element on an already-loaded page:
```gherkin
When I click on element located by `buttonName(Create Product)`
When I wait until element located by `xpath(//input[@name='name'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
When I wait until element located by `xpath(//input[@placeholder='URL'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@placeholder='URL'])`
```

❌ **Bad** - wait used as verification on an already-loaded page (use assertion instead):
```gherkin
When I click on element located by `id(add-to-cart)`
When I wait until element located by `id(remove)` appears
```

✅ **Good** - verify element on same page with assertion:
```gherkin
When I click on element located by `id(add-to-cart)`
Then number of elements found by `id(remove)` is equal to `1`
```

**Summary:**
| Situation | Approach |
|-----------|----------|
| After click that navigates to a new page/URL | ✅ `When I wait until element located by \`<element>\` appears` + ``Then `${current-page-url}` matches `<regex>` `` |
| After click that opens a new tab or modal | ✅ Wait for first unique element + URL check |
| Verifying element state on the current page | ❌ No wait — use `Then` assertion steps |
| Between consecutive actions on same page | ❌ No wait |
| Before every field on the same form | ❌ No wait |

## Step 5: Generate VIVIDUS story

### Output Location

Save generated story files to:
```
src/main/resources/story/web_app/[TestName].story
```

### Fix Formatting Violations

After generating or modifying story files, run the following command to auto-fix all formatting violations:
```
gradlew.bat spotlessApply
```

**DO NOT create (neither as files nor in the chat response):**
- Summary report, coverage table, or step mapping table
- Quick start guides
- README files
- Additional documentation
- Any other markdown files beyond mentioned ones

### Output Files

#### File 1: VIVIDUS Story
**Location**: `src/main/resources/story/web_app/[TestName].story`

```gherkin
Meta:
    @testCaseId [Test Case ID]
    @requirementId [Requirement Id]
    @feature [Feature]
    @priority [0|1|2|3|4]

Scenario: [Descriptive scenario name]
[Steps using ONLY available VIVIDUS syntax]

!-- [MISSING STEP] Comment for any gaps (only if applicable)
!-- [ASSUMPTION] Comment for any assumptions made - REQUIRES VALIDATION (only if applicable)
```

**Meta Tag Guidelines:**
| Tag | Values | Description |
|-----|--------|-------------|
| `@testCaseId` | `TC-XXXXX` | Exact TestRail/Jira ID (e.g., `TC-12345`) |
| `@requirementId` | `REQ-XXXXX` | Linked requirement/user story ID |
| `@feature` | Feature name | Should match feature folder or test suite |
| `@priority` | `1` \| `2` \| `3` \| `4` \| `5` | 1=Blocker, 2=Critical, 3=Major, 4=Minor, 5=Trivial |

**Assumption Comments in Story:**
```gherkin
!-- [ASSUMPTION] TC step said "click submit" but button text is "Save" - using "Save"
When I click on element located by `xpath(//button[text()='Save'])`

!-- [ASSUMPTION] TC doesn't specify wait time, assuming 10 seconds max
When I wait until element located by `caseInsensitiveText(Success)` appears in `PT10S`
```

**Scenario Mapping:**
- One test case typically maps to one scenario
- Split test cases into **separate scenarios by logical action** (e.g., login, verify inventory page, verify product details, return to inventory)
- Use Examples tables to consolidate similar test cases with different data
- **No duplicate scenarios** — each scenario must be unique and included only once per story. Do not repeat the same logical flow in multiple scenarios




## Quality Checklist

### Step Compliance
- [ ] All steps exist in VIVIDUS definitions or composite steps
- [ ] Exact VIVIDUS syntax preserved (no modifications)
- [ ] Valid locator strategies: `xpath`, `cssSelector`, `caseInsensitiveText`, `id`, `name`
- [ ] Missing steps marked with `[MISSING STEP]` and ⚠️ warning

### Locator Quality
- [ ] Element text extracted exactly as displayed (preserve case)
- [ ] Locators are specific (no ambiguous matches)
- [ ] Dynamic content handled with waits

### Coverage
- [ ] Every test case step mapped to VIVIDUS step(s) or marked as gap
- [ ] Coverage percentage calculated
- [ ] Discrepancies documented with impact and recommendations

### Output Quality
- [ ] Meta tags: testCaseId, feature, priority
- [ ] Assumptions marked with `[ASSUMPTION]` comments
- [ ] Discrepancies marked with `[DISCREPANCY]` comments
- [ ] Items requiring validation clearly listed
