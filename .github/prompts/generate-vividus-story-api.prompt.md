---
agent: 'agent'
description: 'Generate VIVIDUS API test automation stories from OpenAPI/Swagger specifications. Creates executable .story files for API endpoints following VIVIDUS syntax and project conventions.'
argument-hint: 'Provide OpenAPI specification URL or file path...'
tools: [vividus/vividus_get_all_features]
---

# Process Overview

1. **Parse** OpenAPI specification
2. **Select** endpoints to automate
3. **Discover** VIVIDUS API capabilities
4. **Design** VIVIDUS API test coverage and structure
5. **Generate** VIVIDUS API stories

---

## Step 1: Parse OpenAPI Specification

**Required Input**: OpenAPI/Swagger specification (URL or file path)

### Parse specification and extract:
- **Base URL**: API server address
- **Endpoints**: All available paths
- **Methods**: GET, POST, PUT, DELETE, PATCH for each path
- **Request schemas**: Parameters, headers, body structure
- **Response schemas**: Status codes, response bodies, headers
- **Authentication**: Security schemes (API key, OAuth, Bearer token)
- **Examples**: Request/response examples if available

**ABORT** further execution if:
- OpenAPI specification is not provided
- Specification is invalid or cannot be parsed
- Specification format is not supported (only OpenAPI 2.0/3.x supported)

When aborting, explain what is missing and request valid OpenAPI specification.

---

## Step 2: Select Endpoints to Automate

Determine which endpoints to generate tests for based on user input:

### Option A: Full Specification
Generate tests for **all** endpoints when user requests complete coverage.

### Option B: Specific Combinations
Generate tests only for user-specified combinations:
- **Path**: `/api/users`, `/api/products`, etc.
- **Method**: GET, POST, PUT, DELETE, PATCH
- **Response Code**: 200, 201, 400, 401, 404, 500, etc.

**Examples**:
- "Create tests for GET /api/users with 200 and 404 responses"
- "Create tests for all POST methods returning 201"
- "Create tests for /api/orders endpoint, all methods"

---

## Step 3: Discover VIVIDUS API Capabilities

### Logic & Flow Planning

**Before choosing any steps**, plan the logical flow of the API test to ensure correctness.
1. Identify API operations sequence (e.g., "Authenticate", "Create resource", "Retrieve resource", "Update resource", "Delete resource")
2. Ensure request dependencies are handled (e.g., "POST user must succeed before GET user by ID", "Authentication token required before protected endpoints")
3. Plan positive and negative scenarios:
   - **Positive**: Valid request → Expected success response (200, 201, 204)
   - **Negative**: Invalid request → Expected error response (400, 401, 403, 404, 409, 500)
4. Verify the test validates failure states correctly (e.g., 404 when resource not found, 401 when unauthorized)

### VIVIDUS API Steps Discovery

1. **MUST** fetch available VIVIDUS API steps using `vividus_get_all_features()` command
2. Read existing API test patterns:
   - `src/main/resources/story/**/*.story` — existing API stories
   - `src/main/resources/steps/**/*.steps` — reusable composite steps for API testing
3. Learn from examples: HTTP methods, request/response validation, authentication patterns

⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

**Strict rules:**
1. **ONLY use steps returned by `vividus_get_all_features()`** — NEVER invent, modify, or assume steps
2. **Preserve exact syntax** — do not alter step parameters or structure
3. **If a required step is NOT available** — mark as `!-- [MISSING STEP]` in story
4. **Do not add indentation or formatting** — maintain VIVIDUS step syntax exactly as defined

---

## Step 4: VIVIDUS API Story Guidelines

### General Rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **HTTP Methods:** Support GET, POST, PUT, DELETE, PATCH
3. **Data Tables:** Use Examples blocks for parameterized API tests
4. **Composite Steps:** Reuse existing composite steps for common API patterns
5. **Variables:** Store and reuse response data using VIVIDUS variables

### API Test Structure

Each API test scenario should follow this pattern:

1. **Setup**: Configure base URL, headers, authentication
2. **Request**: Execute HTTP method with parameters/body
3. **Validation**: Verify status code, response body, headers
4. **Cleanup**: (if needed) Delete created resources

### Authentication Handling

Support common authentication methods from OpenAPI specification:
- **API Key**: Header or query parameter
- **Bearer Token**: Authorization header
- **Basic Auth**: Username/password
- **OAuth2**: Token-based authentication

**Example**:

```gherkin
Given I initialize story variable `apiKey` with value `#{envVars.API_KEY}`
When I set request headers:
|name          |value           |
|Authorization |Bearer ${apiKey}|
```

### Request Body Handling

For POST/PUT/PATCH requests with JSON bodies:

✅ **Good** - inline JSON for simple bodies:

```gherkin
When I set request body: {"name": "Test User", "email": "test@example.com"}
```

### Response Validation

Always validate at minimum:
1. **Status code**: Verify expected HTTP status
2. **Response schema**: Check structure matches OpenAPI spec
3. **Critical fields**: Validate key response values

**Example**:

```gherkin
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.id` is equal to 1
Then JSON element value from `${response}` by JSON path `$.name` is equal to `Test User`
```

### Parameterization with Examples

Use Examples tables for testing multiple scenarios:

```gherkin
Scenario: Verify GET /api/users with different status codes
When I execute HTTP GET request for resource with relative URL `/api/users/<userId>`
Then response code is equal to `<statusCode>`
Examples:
|userId|statusCode|
|123   |200       |
|999   |404       |
|abc   |400       |
```

---

## Step 5: Generate VIVIDUS API Story

### Output Folder Structure

Create folder for generated API tests:

```text
src/main/resources/story/generated/api/[ServiceName]/
└── [endpoint-name].story     # VIVIDUS API story file
```

**DO NOT create:**
- Summary reports
- README files
- Additional documentation
- Any markdown files

### Story File Structure

**Location**: `src/main/resources/story/generated/api/[ServiceName]/[endpoint-name].story`

**Meta Tag Guidelines for API Tests**:

| Tag | Format | Description |
|-----|--------|-------------|
| `@api` | Fixed | Marks as API test |
| `@endpoint` | `GET /api/users` | HTTP method + path |
| `@responseCode` | `200`, `404`, `500` | Expected status code |

**Naming Convention**:
- File: `[method]-[resource]-[status].story`
- Examples: `get-users-200.story`, `post-user-201.story`, `get-user-404.story`

---

## Quality Checklist for API Stories

### Step Compliance

- [ ] All steps exist in VIVIDUS API definitions or composite steps
- [ ] Exact VIVIDUS syntax preserved (no modifications)
- [ ] Missing steps marked with `!-- [MISSING STEP]` comment

### API Test Coverage

- [ ] HTTP method correct (GET, POST, PUT, DELETE, PATCH)
- [ ] Request path matches OpenAPI specification
- [ ] All required headers included (authorization, content-type)
- [ ] Request body structure matches schema (for POST/PUT/PATCH)
- [ ] Status code validation included
- [ ] Response body validation covers critical fields

### Response Validation

- [ ] Status code verified
- [ ] Required response fields validated with JSON path
- [ ] Data types match schema (string, number, boolean, array)
- [ ] Nested objects validated if critical to business logic

### Story Quality

- [ ] Meta tags: @api, @endpoint, @responseCode
- [ ] Scenario name descriptive and includes HTTP method
- [ ] File name follows convention: `[method]-[resource]-[status].story`
- [ ] Comments explain any gaps or assumptions
- [ ] Variables used for environment-specific values (base URL, API keys)
