---
name: generate-vividus-api-tests
description: 'Generate VIVIDUS API test automation stories from OpenAPI/Swagger specifications. Creates executable .story files for API endpoints following VIVIDUS syntax and project conventions. Use when: creating API tests, automating REST endpoints, generating test stories from Swagger docs.'
argument-hint: 'Provide OpenAPI specification file path or content...'
---

# Process Overview


1. **Retrieve** OpenAPI specification schema for runtime validation
2. **Parse** OpenAPI specification
3. **Select** endpoints to automate
4. **Discover** VIVIDUS API capabilities
5. **Design** VIVIDUS API test coverage and structure
6. **Generate** VIVIDUS API stories

---

## Step 1: Retrieve OpenAPI Specification Schema

Before running test scenarios, retrieve the schema from the OpenAPI specification **once** in a **separate setup story** and store it in **next_batches-level variables** so all stories in subsequent batches can reuse it.

### Implementation

Create a **setup story file** named with a `00-` prefix (e.g., `00-get-schema.story`) to guarantee it executes **first** alphabetically before all other stories in the folder.

This story fetches the OpenAPI spec and saves the component schemas to `next_batches` variables:

```gherkin
Description: Retrieve OpenAPI schema for runtime validation

Meta:
    @api
    @setup

Scenario: Getting schema from OpenAPI specification
When I execute HTTP GET request for resource with URL `[swagger-json-url]`
Then response code is equal_to `200`
When I save JSON element from `${response}` by JSON path `$.components.schemas.[SchemaName]` to next_batches variable `[schemaVarName]`
```

**For array responses**, initialize an additional next_batches variable wrapping the schema:

```gherkin
Given I initialize next_batches variable `arraySchema` with value `{"type":"array","items":${objectSchema}}`
```

Other story files reference the schema via `${schemaVarName}` — **no Lifecycle block needed** in individual stories.

Use `${schemaVarName}` in `Then JSON ... is valid against schema` steps — **never hardcode** the JSON Schema in stories.

---

## Step 2: Parse OpenAPI Specification

**Required Input**: OpenAPI/Swagger specification (file path or content)

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

## Step 3: Select Endpoints to Automate

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

## Step 4: Discover VIVIDUS API Capabilities

### Logic & Flow Planning

**Before choosing any steps**, plan the logical flow of the API test to ensure correctness.
1. Identify API operations sequence (e.g., "Authenticate", "Create resource", "Retrieve resource", "Update resource", "Delete resource")
2. Ensure request dependencies are handled (e.g., "POST user must succeed before GET user by ID", "Authentication token required before protected endpoints")
   - When testing GET or DELETE for a resource that may not exist, include a **prerequisite POST/creation step** within the same scenario to guarantee the resource exists. Add a `!--` comment explaining the dependency (e.g., `!-- Create order first to ensure it exists for retrieval`).
   - When testing DELETE, after a successful deletion, include a **verification GET request** for the same resource ID and assert a `404` response to confirm the resource no longer exists.
3. Plan positive and negative scenarios:
   - **Positive**: Valid request → Expected success response (200, 201, 204)
   - **Negative**: Invalid request → Expected error response (400, 401, 403, 404, 409, 500)
4. Verify the test validates failure states correctly (e.g., 404 when resource not found, 401 when unauthorized)

### VIVIDUS API Steps Discovery

1. **MUST** fetch available VIVIDUS API steps by calling the MCP tool matching pattern `vividus_get_all_features`
   - **ABORT** if the VIVIDUS MCP tool is not available or not connected. Instruct the user to connect the VIVIDUS MCP server before proceeding. Without this tool, valid steps cannot be discovered and stories will contain incorrect syntax.
2. Read existing API test patterns:
   - `src/main/resources/story/**/*.story` — existing API stories
   - `src/main/resources/steps/**/*.steps` — reusable composite steps for API testing
3. Learn from examples: HTTP methods, request/response validation, authentication patterns

⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

⚠️ **DRY Rule:** If two or more steps (e.g., initialize variables, set headers + request body + POST + assert status) repeat two or more times across multiple stories, **extract it into a composite step** in `src/main/resources/steps/api/[resource].steps`. The composite step must be **self-contained** — it should initialize all dynamic variables (`scenario` scope) internally (e.g., generate IDs, URLs) rather than accepting them as parameters. Calling stories use the variables set by the composite (e.g., `${coverId}`, `${bookId}`) for subsequent assertions. Stories must call the composite step instead of duplicating the inline sequence.

**Strict rules:**
1. **ONLY use steps returned by the MCP tool matching pattern `vividus_get_all_features`** — NEVER invent, modify, or assume steps
2. **Preserve exact syntax** — do not alter step parameters or structure. Pay attention to which parameters use backticks and which do not:
   - `$elementsNumber` in `Then number of JSON elements from \`$json\` by JSON path \`$jsonPath\` is $comparisonRule $elementsNumber` — **NO backticks** around the number
   - `$comparisonRule` — **NO backticks** (e.g., `equal_to`, `greater_than`)
   - `$responseCode`, `$expectedValue`, `$json`, `$jsonPath` — **WITH backticks**
3. **If a required step is NOT available** — mark as `!-- [MISSING STEP]` in story
4. **Do not add indentation or formatting** — maintain VIVIDUS step syntax exactly as defined

---

## Step 5: VIVIDUS API Story Guidelines

### General Rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **HTTP Methods:** Support GET, POST, PUT, DELETE, PATCH
3. **Data Tables:** Use Examples blocks for parameterized API tests
4. **Composite Steps:** Reuse existing composite steps for common API patterns
5. **Variables:** Store and reuse response data using VIVIDUS variables
6. **No Hardcoded URLs:** Never hardcode base URLs directly in stories or composite steps. Store the API base URL in `src/main/resources/properties/environment/api/environment.properties` as a custom variable (e.g., `variables.api-base-url=https://example.com/api/v1`) and reference it in steps via `${api-base-url}`. This enables easy environment switching (dev, staging, prod) without modifying test files.

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

**Re-executability Rule**: Tests MUST NOT hardcode IDs or unique values in request bodies. Always use generated or dynamic values (e.g., `#{generate(...)}`, timestamps, random strings) to ensure tests can be re-executed without conflicts.

❌ **Bad** - hardcoded values prevent re-execution:

```gherkin
Given request body: {"id": 999, "name": "Test User", "email": "test@example.com"}
```

✅ **Good** - dynamic values inside a composite step ensure re-executability and DRY:

```
!-- In src/main/resources/steps/api/[resource].steps:
Composite: When I create [Resource] with random data
Given I initialize scenario variable `resourceId` with value `#{generate(Number.numberBetween '5000','9999')}`
Given I initialize scenario variable `resourceName` with value `Test Resource ${resourceId}`
When I set request headers:
|name        |value           |
|Content-Type|application/json|
Given request body: {"id": ${resourceId}, "name": "${resourceName}"}
When I execute HTTP POST request for resource with URL `[base-url]/api/v1/[resources]`
Then response code is equal_to `200`
```

✅ **Good** - calling the composite step in a story:

```gherkin
Scenario: Creating resource with valid data
When I create [Resource] with random data
Then JSON element value from `${response}` by JSON path `$.id` is equal_to `${resourceId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal_to `${resourceName}`
```

### Response Validation

Always validate at minimum:
1. **Status code**: Verify expected HTTP status
2. **Response schema**: Validate response structure, data types, and required fields against the OpenAPI specification using JSON Schema validation
3. **Critical fields**: Validate key response values

#### Schema Verification Rule

For every endpoint with a response body, include `Then JSON ... is valid against schema` with a JSON Schema from the OpenAPI `components/schemas`. The schema must cover all fields, types, formats, nullability (`"type": ["string", "null"]`), and required fields.

```gherkin
!-- Single object
Then JSON `${response}` is valid against schema `{"type":"object","properties":{"id":{"type":"integer"},"name":{"type":"string"}},"required":["id","name"]}`

!-- Array
Then JSON `${response}` is valid against schema `{"type":"array","items":{"type":"object","properties":{"id":{"type":"integer"},"name":{"type":"string"}},"required":["id","name"]}}`
```

#### Field Value Verification Rule

For POST, PUT, and GET-by-ID endpoints, **always verify that response field values match the sent/expected data**. Schema validation only checks structure and types — it does NOT verify actual values.

Use `Then JSON element value from ... by JSON path ... is equal_to` for each field that was generated or sent in the request body:

```gherkin
!-- After POST/PUT: verify response contains the values that were sent
Then JSON element value from `${response}` by JSON path `$.id` is equal_to `${newId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal_to `Test User ${newId}`

!-- After GET by ID: verify the retrieved resource has the expected values
Then JSON element value from `${response}` by JSON path `$.id` is equal_to `${resourceId}`
```

**Rule**: Every field that was explicitly set in the request body or used for resource creation MUST have a corresponding value assertion in the response.

### Parameterization with Examples

Use Examples tables for testing multiple scenarios:

```gherkin
Scenario: Verify GET /api/users with different status codes
When I execute HTTP GET request for resource with relative URL `/api/users/<userId>`
Then response code is equal_to `<statusCode>`
Examples:
|userId|statusCode|
|123   |200       |
|999   |404       |
|abc   |400       |
```

---

## Step 6: Generate VIVIDUS API Story

### Output Folder Structure

Create folder for generated API tests:

```text
src/main/resources/story/rest_api/[ServiceName]/
└── [endpoint-name].story     # VIVIDUS API story file
```

**ServiceName**: Derive from `info.title` in the OpenAPI spec. Use PascalCase with spaces removed. Example: `"Swagger Petstore"` → `SwaggerPetstore`, `"User Management API"` → `UserManagementAPI`.

**DO NOT create:**
- Summary reports
- README files
- Additional documentation
- Any markdown files

### Story File Structure

**Location**: `src/main/resources/story/rest_api/[ServiceName]/[endpoint-name].story`

**Meta Tag Guidelines for API Tests**:

| Tag | Format | Description |
|-----|--------|-------------|
| `@api` | Fixed | Marks as API test |
| `@endpoint` | `GET /api/users` | HTTP method + path |
| `@responseCode` | `200`, `404`, `500` | Expected status code |

**Naming Convention**:
- **Setup story**: `00-get-schema.story` — always runs first (alphabetical order), retrieves OpenAPI schema into batch variables
- **Test stories**: `[method]-[resource]-[status].story`
- `[resource]` is the **last meaningful path segment** (exclude path parameters):
  - `/store/inventory` → `inventory`
  - `/store/order` → `order`
  - `/store/order/{orderId}` → `order` (ignore `{orderId}`)
  - `/pet/{petId}/uploadImage` → `uploadImage`
- Examples: `00-get-schema.story`, `get-inventory-200.story`, `post-order-200.story`, `get-order-404.story`
