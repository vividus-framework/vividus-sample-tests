---
agent: 'agent'
description: 'Generate VIVIDUS test automation stories from test specs for web applications. It enables the conversion of input test specs into executable .story files following VIVIDUS syntax and project conventions.'
model: 'Claude Sonnet 4.5'
argument-hint: 'Enter your test spec...'
---

# VIVIDUS Story Generation

## Input Requirements

The test spec should include:
- Test case IDs and names
- Preconditions (if any)
- Test steps with expected results
- Target URL(s) to test

---

## ⛔ Critical Constraint: Strict VIVIDUS Step Adherence

**You MUST strictly adhere to available VIVIDUS steps. This is non-negotiable.**

### Rules:

1. **ONLY use steps that exist** in the VIVIDUS step definitions retrieved from `vividus_get_all_features` VIVIDUS tool
2. **NEVER invent, modify, or assume steps** that are not explicitly listed
3. **Preserve exact step syntax** — including parameter names, order, and formatting
4. **If a required action has no matching VIVIDUS step:**
   - **DO NOT** silently skip it or create a fake step
   - **HIGHLIGHT IT** clearly in the output using this format:

```
⚠️ MISSING STEP REQUIRED:
   Action needed: {describe the action from test spec}
   Closest available step: {if any similar step exists, list it}
   Recommendation: {suggest creating composite step or manual workaround}
```

5. **After generating the story**, provide a summary section listing:
   - ✅ All test case actions successfully mapped to VIVIDUS steps
   - ⚠️ All test case actions that could NOT be mapped (with details)

6. **If the test spec is ambiguous or incomplete:**
   - Ask for clarification before proceeding
   - Do NOT make assumptions about intended behavior

---

## Workflow

> 💡 **Tip:** Steps 1 and 2 can be executed in parallel as they are independent.

### Step 1: Explore Available VIVIDUS Steps

Use the `vividus_get_all_features` tool to retrieve available VIVIDUS automation steps.

---

### Step 2: Explore Existing Stories and Composite Steps

Read existing resources to learn patterns and conventions:

**Analyze:**
- `src/main/resources/story/**/*.story` — Existing stories
- `src/main/resources/steps/*.steps` — Reusable composite steps

**Key Patterns to Extract:**
- Lifecycle and Examples usage (transformers, data tables)
- Scenario structure and naming
- How composite steps are defined and called

> ⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

---

### Step 3: Explore the Target Page Using Browser Tools

Use available browser tools to explore the target page according to scenarios in the test spec.

**Exploration Actions:**
1. Navigate to the target URL
2. Take a page snapshot to understand page structure
3. Identify key elements mentioned in the test spec e.g.:
   - Form fields (inputs, dropdowns, checkboxes, buttons)
   - Interactive elements (menus, modals, accordions)
   - Visual components (banners, carousels, images)
4. Note exact element text, attributes, and hierarchy for building locators
5. Test interactions to verify element behaviors

**Element Identification Priorities:**
- Get unique IDs, data-testid, aria-labels for stable locators
- Get exact button/link text for text based locators
- Understand parent-child relationships for contextual steps

---

### Step 4: Write VIVIDUS Story

Generate a `.story` file following VIVIDUS syntax and project conventions.

**Output File Location:**
`src/main/resources/story/generated/{feature_name}.story`

**Scenario Mapping:**
- One test case typically maps to one scenario
- Use Examples tables to consolidate similar test cases with different data
- Split complex test cases into multiple focused scenarios if needed

**Coding Guidelines:**

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **Locators:** Prefer stable locators (IDs, data-testid, aria-labels) over fragile ones (indexes, complex xpaths)
3. **Data Tables:** Use Examples blocks for parameterized scenarios
4. **Composite Steps:** Reuse existing composite steps; propose new ones for repeated patterns
5. **Contextual Steps:** When using parent element context, ensure child locators are relative

---

## Required Outputs

**Only TWO files must be generated:**

| # | Output | Location | Description |
|---|--------|----------|-------------|
| 1 | **Test Story** | `src/main/resources/story/generated/{feature_name}.story` | VIVIDUS test automation story file |
| 2 | **Coverage Report** | `{feature_name}-Coverage-Report.md` | Step mapping and coverage analysis |

**DO NOT create:**
- Quick start guides
- README files
- Additional documentation
- Any other markdown files beyond the coverage report

---

## Coverage Report Template

Generate a coverage report file: `{feature_name}-Coverage-Report.md`

The coverage report must include:

```markdown
# {feature_name} - Step Coverage Report

**Story File:** `src/main/resources/story/generated/{feature_name}.story`

---

## ✅ Successfully Mapped Actions

| Test Case | Action | VIVIDUS Step Used |
|-----------|--------|-------------------|
| TC-XX | {action description} | {exact step used} |
| ... | ... | ... |

---

## ⚠️ Unmapped Actions (Require Attention)

| Test Case | Action Needed | Issue | Recommendation |
|-----------|---------------|-------|----------------|
| TC-XX | {action description} | No matching step exists | {suggestion} |
| ... | ... | ... | ... |

---

## 📝 New Composite Steps Needed

| Composite Name | Purpose | Steps to Include |
|----------------|---------|------------------|
| When I {name} | {description} | {list of steps} |

---

## 📊 Test Coverage Statistics

| Metric | Count |
|--------|-------|
| Total Test Cases | X |
| Total Scenarios Generated | X |
| Fully Automated Actions | X |
| Partially Automated Actions | X |
| Manual Testing Required | X |

---

## ✅ Quality Checklist

- [ ] All test cases from spec are covered
- [ ] Every step exists in VIVIDUS step definitions or composite steps
- [ ] Missing steps are highlighted with ⚠️ warnings
- [ ] Steps use exact VIVIDUS syntax
- [ ] Locators match actual page elements
- [ ] Examples/data tables properly formatted
- [ ] Composite steps used where appropriate
```
