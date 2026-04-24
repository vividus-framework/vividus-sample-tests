---
name: generate-vividus-web-tests
description: 'Generate VIVIDUS test automation stories from test cases for web applications. Creates executable .story files following VIVIDUS syntax and project conventions. Use when: automating web test cases, converting manual tests to VIVIDUS stories, generating web UI test automation.'
argument-hint: 'Enter your test case...'
---

## Process Overview

1. **Retrieve** test cases to automate
2. **Execute** test cases with Playwright
3. **Analyze** test case and map each action to a VIVIDUS step
4. **Apply** VIVIDUS story writing guidelines
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

Use Playwright MCP to execute test cases and collect element locators for VIVIDUS story generation in Step 5.

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
3. Flag with an `[ASSUMPTION]` inline comment in the story file

Example assumptions:

| Situation | Assumption Made |
|-----------|-----------------|
| Button text unclear in TC | Used actual text from app exploration |
| Sort order not specified | Assumed descending by date (most recent first) |
| Element locator not unique | Used more specific parent context |
| Expected state not defined | Assumed element should be visible and enabled |

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

## Step 3: Analyze test case and map each action to a VIVIDUS step

### Logic & Flow Planning

**Before choosing any steps**, write out the logical flow of the test to ensure it makes functional sense.
1. Identify the *high-level* actions (e.g., "Login", "Navigate to User Profile", "Change Password").
2. Ensure the sequence handles state changes (e.g., "Page must be reloaded after saving" or "Modal must be closed").
3. Check for specific negative scenarios: Ensure the test verifies the *fail state* (e.g., "Error message visible") and doesn't accidentally succeed if the error is missing.

### Discovery

VIVIDUS capabilities and project discovery:
1. **MUST** fetch available VIVIDUS steps via **VIVIDUS MCP**:
   - Call the MCP tool matching pattern `vividus_get_all_features`
   - **ABORT** if the VIVIDUS MCP tool is not available or not connected. Instruct the user to connect the VIVIDUS MCP server before proceeding. Without this tool, valid steps cannot be discovered and stories will contain incorrect syntax.
2. **MUST** read existing resources to learn patterns and conventions:
   - `src/main/resources/story/**/*.story` - existing stories
   - `src/main/resources/steps/*.steps` - reusable composite steps
3. **MUST** review Lifecycle and Examples usage (transformers, data tables), scenario structure and naming, meta tags
4. **OPTIONAL**: obtain additional VIVIDUS documentation via **context7 MCP** when step syntax is unclear or additional capabilities need to be explored:
   - Call the MCP tool matching pattern `context7_resolve-library-id` with query `vividus` to get the VIVIDUS library ID
   - Call the MCP tool matching pattern `context7_query-docs` with the resolved library ID to look up specific step documentation, configuration options, or plugin capabilities

⚠️ **Priority Rule:** Two sources of valid steps are allowed: (1) composite steps defined in project `.steps` files - these take precedence, and (2) steps returned by VIVIDUS MCP. If a composite step exists that accomplishes the same action as an MCP-returned step, always use the composite step.

**Strict** rules to adhere:
1. **ONLY use steps from project `.steps` files OR VIVIDUS MCP results** - NEVER invent, modify, or assume steps that are not explicitly listed in either source
2. **Preserve exact syntax** - do not modify step parameters or structure
3. **If a required step is NOT available in either MCP results or project `.steps` files** - DO NOT silently ignore, mark as `[MISSING STEP]`

## Step 4: VIVIDUS Story Guidelines

### General rules

1. **Locators:** Follow the **Locator Stability Hierarchy** below to ensure stability.
2. **Expressions:** Use VIVIDUS expressions instead of hardcoded dynamic values - see **Use VIVIDUS Expressions Instead of Hardcoded Values** below.
3. **Data Tables:** Use Examples blocks **only** when a scenario must run with multiple distinct data sets. Do NOT use Examples for a single data set - inline values or expressions directly.
4. **Composite Steps:** Propose new composite steps for repeated action patterns.
5. **Contextual Steps:** When using parent element context, ensure child locators are relative.

### Use VIVIDUS Expressions Instead of Hardcoded Values

NEVER hardcode dynamic values (dates, IDs, names, emails, random data). Use VIVIDUS expressions instead so stories remain re-executable without manual edits.

Key built-in expressions:
- **Random integer**: `#{randomInt($minInclusive, $maxInclusive)}` - e.g. `#{randomInt(1000, 9999)}`
- **Generate date**: `#{generateDate($period, $outputFormat)}` - e.g. `#{generateDate(P, yyyy-MM-dd)}` (today), `#{generateDate(P1D, yyyy-MM-dd)}` (tomorrow)
- **Fake data** (via DataFaker): `#{generate($Provider.$method)}` - e.g. `#{generate(Name.firstName)}`, `#{generate(Internet.emailAddress)}`, `#{generate(Address.fullAddress)}`
- **Pick random from list**: `#{anyOf($value1, $value2, $value3)}`
- **String transforms**: `#{toLowerCase($input)}`, `#{toUpperCase($input)}`

❌ **Bad** - hardcoded values:

```gherkin
When I enter `John` in field located by `xpath(//input[@name='firstName'])`
When I enter `john.doe@test.com` in field located by `xpath(//input[@name='email'])`
When I enter `2026-04-24` in field located by `xpath(//input[@name='date'])`
```

✅ **Good** - generated values:

```gherkin
When I enter `#{generate(Name.firstName)}` in field located by `xpath(//input[@name='firstName'])`
When I enter `#{generate(Internet.emailAddress)}` in field located by `xpath(//input[@name='email'])`
When I enter `#{generateDate(P, yyyy-MM-dd)}` in field located by `xpath(//input[@name='date'])`
```

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

## Step 5: Generate VIVIDUS story

### Output

Create a new folder for each test case. User will review and move story files to the appropriate location after approval.

**Location**: `src/main/resources/story/generated/TC-XXXXX-[TestName]/[TestName].story`

**DO NOT create** any additional files (README, summary reports, documentation, etc.) - only the `.story` file.

```gherkin
Meta:
    @testCaseId [Test Case ID]
    @requirementId [Requirement Id]
    @feature [Feature]
    @priority [1|2|3|4|5]

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
When I click on element located by `buttonName(Save)`

!-- [ASSUMPTION] TC doesn't specify wait time, assuming 10 seconds max
When I wait until element located by `caseInsensitiveText(Success)` appears in `PT10S`
```

**Scenario Mapping:**
- One test case typically maps to one scenario
- Split complex test cases into multiple focused scenarios if needed
