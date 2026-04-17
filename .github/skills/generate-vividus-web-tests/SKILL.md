---
name: generate-vividus-web-tests
description: 'Generate VIVIDUS test automation stories from test cases for web applications. Creates executable .story files following VIVIDUS syntax and project conventions. Use when: automating web test cases, converting manual tests to VIVIDUS stories, generating web UI test automation.'
argument-hint: 'Enter your test case...'
allowed-tools: zsh
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

## No-Playwright = No-Assumptions Policy (ABORT)
If Playwright execution is unavailable for any reason (e.g., “browser backend is closed”, MCP not connected, navigation cannot be performed), the skill MUST NOT proceed with any “deterministic rewrite”, “known locators”, or any other inferred implementation.

CRITICAL RULE: Without Playwright execution, ABORT story generation.

What to do instead:
Stop immediately and inform the user that Playwright execution is required to:
- discover accurate locators and page structure,
- validate current UI text and states,
- avoid generating incorrect steps.

2.Request the minimum required input to continue:
- confirmation that Playwright/MCP is available again, or
- the target environment URL + credentials (if needed) + existing stable locators provided by the user.

Forbidden behaviors (when Playwright cannot run)
- Using “known” application locators (e.g., SauceDemo locators) without verification
- Guessing element identifiers, text values, or page structure
- Generating steps based on prior knowledge of the app
- Replacing missing exploration with JavaScript extraction or any other workaround

Required abort message template:
ABORTED: Playwright execution is not available (browser backend is closed). I cannot reliably discover locators or validate UI behavior, so I will not generate or rewrite VIVIDUS steps using assumptions. Please restore Playwright/MCP connectivity and rerun, or provide verified locators and required environment details.

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
3. Flag for user validation in summary report

Example assumptions:
| Situation | Assumption Made |Marked As |
|-----------|-----------------|-----------|
| Button text unclear in TC | Used actual text from app exploration | 🔵 Assumed |
| Sort order not specified | Assumed descending by date (most recent first) | 🔵 Assumed |
| Element locator not unique | Used more specific parent context | 🔵 Assumed |
| Expected state not defined | Assumed element should be visible and enabled | 🔵 Assumed |

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

### Coverage Mapping

In summary report for each test case step, assess coverage status and notes:

| TC Step | Action | Status | Notes |
|---------|--------|--------|-------|
| 1 | Log in as Global Admin | ✅ Covered | Requires navigation + cookie/auth handling |
| 2 | Navigate to Companies page | ✅ Covered | Click + wait for page load |
| 3 | Verify tooltip on hover | ⚠️ Gap | No tooltip verification step in VIVIDUS |
| 4 | Drag item to new position | ✅ Covered | Single drag-and-drop step available |
| 5 | Verify sorting order | 🔵 Assumed | Unclear if alphabetical or by date |
| 6 | Check error message style | ❌ Discrepancy | Expected red text, actual is orange |

### Coverage Status Legend
- ✅ **Covered** - Can be implemented with available VIVIDUS steps
- ⚠️ **Gap** - No VIVIDUS step available, manual intervention needed
- ❌ **Discrepancy** - Expected behavior differs from actual
- 🔵 **Assumed** - Input was unclear or incomplete; a best-guess decision was made (requires validation)

## Step 4: VIVIDUS Story Guidelines

### General rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **Locators:** Follow the **Strict Hierarchy** below to ensure stability.
3. **Data Tables:** Use Examples blocks for parameterized scenarios
4. **Composite Steps:** Reuse existing composite steps; propose new ones for repeated patterns
5. **Contextual Steps:** When using parent element context, ensure child locators are relative

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

### Prefer Context + Text Assertions for UI Text Verification (Do NOT Use JavaScript Extraction)

When a test case step requires verifying that any UI text matches an expected value (e.g., labels, headers, messages, list items, table cells, tooltip text, etc.):

DO NOT implement it using JavaScript extraction steps (e.g., When I execute javascript ... and save result...) when the intent is to validate visible text on the page.

MANDATORY RULE: Use context switching + text verification steps instead.

Required sequence:
1. Switch context to the smallest stable container that holds the expected text:
```gherkin
When I change context to element `<container-locator>`
```

2. Verify the text using text assertion steps:
```gherkin
Then text `<expected-text>` exists
```
or (when pattern-based check is needed)
```gherkin
Then text matches `<regex>`
```
Context reset rule (avoid unnecessary context switching):
After completing a check within a context, DO NOT reset context back to the page if you are going to switch context to another element immediately after.

MANDATORY RULE: Reset context back to page level only when:
- all context-specific checks are complete, or
- there is a valid need to interact/verify at the page level.

This prevents redundant steps and keeps scenarios concise and stable.

Example (verify text in a specific page area):
```gherkin
When I change context to element `cssSelector(div.user1-details)`
Then text `John Smith` exists
When I change context to element `cssSelector(div.user2-details)`
Then text `Tom Johns` exists
When I reset context
```

### Use Visual Testing for Multiple Element Verification

**MANDATORY RULE**: When verifying 3 or more elements on a page (text labels, buttons, fields, etc.), you **MUST** use visual baseline testing instead of individual element checks.

**Why**: Visual testing is more efficient, catches unexpected UI changes, and verifies element states (enabled/disabled, selected, etc.) that individual text checks cannot capture.

❌ **Bad** - verifying each element individually:
```gherkin
Then text `Back to Home` exists
Then text `Add Account` exists
Then number of elements found by `xpath(//input[@placeholder='Name'])` is equal to `1`
Then text `Upload logo` exists
Then number of elements found by `buttonName(Save)` is equal to `1`
```

✅ **Good** - visual baseline captures entire page state:
```gherkin
When I establish baseline with name `my-add-account-page`
```

**When to use visual testing**:
- ✅ Verifying page layout, structure, elements and their states (3+ elements)
- ❌ Single element verification after an action
- ❌ Dynamic content that changes frequently

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

### Synchronize After Navigation

**CRITICAL RULE**: When navigating to a new page or opening a new tab, **ALWAYS** add a wait step for FIRST **interactive element** on that page or tab. This ensures the page has fully loaded and all subsequent interactive elements are available.

**Why**: Waiting for the first interactive element on a page guarantees that:
- The page DOM is fully rendered
- JavaScript has executed and initialized components
- All form fields, buttons, and other interactive elements are ready
- Subsequent steps won't fail due to elements not being available yet

✅ **Good** - wait for first interactive element after navigation:
```gherkin
When I click on element located by `buttonName(Add Product)`
When I wait until element located by `caseInsensitiveText(Create Product)` appears

!-- Now safe to interact with form fields without additional waits
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
When I enter `${campaignName}` in field located by `xpath(//input[@placeholder='URL'])`
```

❌ **Bad** - no synchronization after navigation:
```gherkin
When I click on element located by `buttonName(Add Product)`
!-- Missing wait - next step may fail if page hasn't loaded
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
```

❌ **Bad** - waiting before every field (unnecessary):
```gherkin
When I click on element located by `buttonName(Create Product)`
When I wait until element located by `xpath(//input[@name='name'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
When I wait until element located by `xpath(//input[@placeholder='URL'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@placeholder='URL'])`
```

**When to wait:**
- ✅ After clicking navigation links (new page loads)
- ✅ After clicking buttons that open new tabs or modals
- ✅ After dropdown selections that dynamically load/show new fields
- ✅ After form submissions that redirect to different pages
- ❌ Before every field on the same page (only first element needed)
- ❌ Between consecutive actions on already-loaded elements

### Prefer URL Validation for “Verify <Page> Page Is Displayed” (When URL Is Descriptive)

When a test case step says “Verify <Page> page is displayed/loaded/opened”, you MUST first consider validating the page by checking the current page URL, if the URL contains a clear, stable, and reasonable page identifier (e.g., /inventory, /login, /checkout, /users).

Priority Rule: URL-based validation takes precedence over element-based validation when the URL is descriptive and stable.

Required sequence:
1. Validate by URL first (preferred): Use a URL verification step if available in the discovered VIVIDUS steps
2. Only if URL validation is not possible or URL is not descriptive, validate by waiting for a page-unique element

Example (Inventory page):

Preferred (URL-based):
```gherkin
Then `${current-page-url}` matches `.+/inventory.+`
or
Then `#{extractPathFromUrl(${current-page-url})}` is equal to `/inventory.html`
```

Fallback (element-based):
```gherkin
When I wait until element located by `cssSelector([data-test='product-sort-container'])` appears
```

## Step 5: Generate VIVIDUS story

### Output Folder Structure
Create a new folder for each test case in project root for user review:

```
src/main/resources/story/generated/TC-XXXXX-[TestName]/
├── [TestName].story          # VIVIDUS story file
└── test-data/                # Generated test data (images, files, etc.)
    └── [any required files]
```

User will review and move story files to appropriate place after approval.

**DO NOT create:**
- Quick start guides
- README files
- Summary reports
- Additional documentation
- Any markdown files

### Output Files

#### File 1: VIVIDUS Story
**Location**: `src/main/resources/story/generated/TC-XXXXX-[TestName]/[TestName].story`

```gherkin
Meta:
    @testCaseId [Test Case ID]
    @requirementId [Requirement Id]
    @feature [Feature]
    @priority [0|1|2|3|4]

Scenario: [Descriptive scenario name]
[Steps using ONLY available VIVIDUS syntax]

!-- [MISSING STEP] Comment for any gaps
!-- [ASSUMPTION] Comment for any assumptions made - REQUIRES VALIDATION
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
- Use Examples tables to consolidate similar test cases with different data
- Split complex test cases into multiple focused scenarios if needed

#### File 2: Test Data (if needed)
**Location**: `src/main/resources/story/generated/TC-XXXXX-[TestName]/test-data/`
- Upload images, JSON files, or any test data generated during exploration
- Reference in story using relative path: `test-data/[filename]`

---

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
- [ ] All report sections completed
