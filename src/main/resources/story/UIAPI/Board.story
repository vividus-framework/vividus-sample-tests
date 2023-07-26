Description: Trello board check

GivenStories:/story/precondition/Precond.story#{group:createBoardAndLogin}
Lifecycle:
Examples:
/story/input/input.table


Scenario: Verify that user can create card on UI
When I wait until element located by `<add-another-list>` appears
When I click on element located by `<add-another-list>`
When I wait until element located by `<list-name-field>` appears
When I enter `#{generate(Ancient.hero '5', '10', 'false')}` in field located by `<list-name-field>`
When I click on element located by `<add-list-button>`
When I click on element located by `<add-card-button>`
When I execute steps while counter is less than or equal to `10` with increment `3` starting from `1`:
|step                                                                                                                                |
|Given I initialize scenario variable `card-name` with value `#{generate(Ancient.hero '5', '10', 'false')}`                          |
|When I enter `${card-name}` in field located by `<card-name-field>`                                                                 |
|When I click on element located by `<card-submit-button>`                                                                           |
|When I wait until element located by `By.xpath(//div[@class='list js-list-content']//span[contains(text(),'${card-name}')])` appears|


Scenario: Verify that user can delete board with API
Given I initialize STORY variable `board_name` with value `#{replaceAllByRegExp(^(.*[\\\/]), , #{extractPathFromUrl(${current-page-url})})}`
Given I initialize STORY variable `url` with value `${main_url}/1/members/me/boards?fields=id,name&name=${board_name}&key=${key}&token=${token}`
When I execute HTTP GET request for resource with URL `${url}`
Then content type of response body is equal to `application/json`
Then `${response-code}` is equal to `200`
When I save JSON element from context by JSON path `[0].id` to STORY variable `id_board`
Given I initialize STORY variable `url2` with value `${main_url}/1/boards/#{removeWrappingDoubleQuotes(${id_board})}?key=${key}&token=${token}`
When I execute HTTP DELETE request for resource with URL `${url2}`
Then `${response-code}` is equal to `200`


Scenario: Verify that user can log out of trello on UI
When I log out