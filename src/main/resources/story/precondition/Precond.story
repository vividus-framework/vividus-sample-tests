Description: Create board and login
Lifecycle:
Examples:
/story/input/input.table


Scenario: Verify that user can create board with API
Meta:
@group createBoardAndLogin
Given I initialize STORY variable `url` with value `${main_url}/1/boards?key=${key}&token=${token}`
Given I initialize STORY variable `name` with value `#{toLowerCase(#{generate(Ancient.god '10', '25', 'false')})}`

When I set request headers:
|name        |value           |
|Content-Type|application/json|
Given request body: {
                    "name": "${name}"
                    }
When I execute HTTP POST request for resource with URL `${url}`
Then content type of response body is equal to `application/json`
Then `${response-code}` is equal to `200`
Then JSON element by JSON path `$.name` is equal to `"${name}"` ignoring extra fields
When I save JSON element from context by JSON path `$.id` to STORY variable `id_board`
When I save JSON element from context by JSON path `$.name` to STORY variable `name_board`


Scenario: Verify that user can login to trello with valid creds on UI
Meta:
@group createBoardAndLogin
When I login with email `${email}` and password `${password}`


Scenario: Verify that user can open created board on UI
Meta:
@group createBoardAndLogin
When I wait until element located by `By.xpath((//div[@title='<name_board>'])[1])` appears
When I click on element located by `By.xpath((//div[@title='<name_board>'])[1])`
Then the page with the URL containing '<name_board>' is loaded
Examples:
{transformer=FROM_LANDSCAPE}
|name_board         |#{removeWrappingDoubleQuotes(${name_board})}     |