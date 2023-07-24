Description: Trello board check

Lifecycle:
Examples:
/story/input/input.table


Scenario: Verify that user can login to trello with valid creds
When I login with email `kadixah655@ridteam.com` and password `TRELLO@123456789!`


Scenario: Verify that user can create a new board
When I click on element located by `<create-button>`
When I click on element located by `<create-board-button>`
Given I initialize story variable `board-name` with value `#{toLowerCase(#{generate(Ancient.god '10', '25', 'false')})}`
When I enter `${board-name}` in field located by `<board-title-field>`
When I click on element located by `<submit-board-button>`
Then the page with the URL containing '${board-name}' is loaded


Scenario: Verify that user can create card
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


Scenario: Verify that user can delete board
When I click on element located by `<board-actions-menu>`
When I click on element located by `<more-button>`
When I click on element located by `<close-button>`
When I click on element located by `<close-board-menu>`
When I wait until element located by `<delete-board-button>` appears
When I click on element located by `<delete-board-button>`
When I wait until element located by `<delete2-board-button>` appears
When I click on element located by `<delete2-board-button>`
When I wait until element located by `<board-deleted-div>` appears


Scenario: Verify that user can log out of trello
When I log out