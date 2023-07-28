Description: Test demoing VIVIDUS capabilities for Web Applications


Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|login-button           |By.xpath(//a[@class='Buttonsstyles__Button-sc-1jwidxo-0 kTwZBr'])                            |
|email                  |sominasvet@gmail.com                                                                         |
|email-field            |By.id(user)                                                                                  |
|continue-button        |By.id(login)                                                                                 |
|password-field         |By.id(password)                                                                              |
|password               |P7@teS9aqVL                                                                                  |
|login-submit-button    |By.id(login-submit)                                                                          |
|create-new-board-button|By.xpath(//span[text()='Create new board'])                                                  |
|board-title-field      |By.xpath(//input[@class='nch-textfield__input lsOhPsHuxEMYEb lsOhPsHuxEMYEb VkPAAkbpkKnPst'])|
|create-button          |By.xpath(//button[@data-testid='create-board-submit-button'])                                |
|list-name-input        |By.xpath(//input[@class='list-name-input'])                                                  |
|list-add-button        |By.xpath(//input[@class='nch-button nch-button--primary mod-list-add-button js-save-edit'])  |
|add-card               |By.xpath(//span[@class='js-add-a-card'])                                                     |
|card-title-field       |By.xpath(//textarea[@class='list-card-composer-textarea js-card-title'])                     |
|add-card-button        |By.xpath(//input[@value='Add card'])                                                         |
|active-board           |By.xpath(//a[@aria-label='Board with tasks (currently active)'])                             |
|invalid-password       |Lu9iomjlp0                                                                                   |


Scenario: Verify login to Trello
Given I am on page with URL `https://trello.com/`
When I click on element located by `<login-button>`
When I enter `<email>` in field located by `<email-field>`
When I click on element located by `<continue-button>`
When I wait until element located by `<password-field>` appears
When I enter `<password>` in field located by `<password-field>`
When I click on element located by `<login-submit-button>`
Then the page with the URL containing '/svitlanasomina/' is loaded


Scenario: Verify creating the board
When I click on element located by `<create-new-board-button>`
When I enter `Board with tasks` in field located by `<board-title-field>`
When I click on element located by `<create-button>`
When I wait until element located by `<active-board>` appears
Then number of elements found by `<active-board>` is equal to `1`


Scenario: Verify creating the list
When I wait until element located by `<list-name-input>` appears
When I enter `new list` in field located by `<list-name-input>`
When I click on element located by `<list-add-button>`
Then number of elements found by `By.xpath(//div[@data-testid='list-header'])` is equal to `1`


Scenario: Verify adding cards
When I click on element located by `<add-card>`
When I enter `#{generate(numerify 'card####')}` in field located by `<card-title-field>`
When I click on element located by `<add-card-button>`
When I enter `#{generate(numerify 'card####')}` in field located by `<card-title-field>`
When I click on element located by `<add-card-button>`
When I change context to element located `By.xpath((//div[@class='list js-list-content'])[1])`
When I ESTABLISH baseline with name `new_list`
When I COMPARE_AGAINST baseline with name `new_list` ignoring:
|ACCEPTABLE_DIFF_PERCENTAGE|ELEMENT                                               |
|30                        |By.xpath(//div[@class='list-card-details u-clearfix'])|
When I reset context


Scenario: Verify closing the board
When I click on element located by `<active-board>`
When I click on element located by `By.xpath((//button[@aria-label='Board actions menu'])[1])`
When I wait until element located by `By.xpath(//button[@title='Close board'])` appears
When I click on element located by `By.xpath(//button[@title='Close board'])`
When I click on element located by `By.xpath(//button[@title='Close'])`
When I wait until element located by `By.xpath(//h1[text()='Board with tasks is closed.'])` appears
Then number of elements found by `By.xpath(//h1[text()='Board with tasks is closed.'])` is equal to `1`


Scenario: Verify logout from Trello
When I click on element located by `By.xpath(//span[@title='Svitlana Somina (svitlanasomina)'])`
When I click on element located by `By.xpath(//button[@data-testid='account-menu-logout'])`
When I click on element located by `By.id(logout-submit)`
When I wait until element located by `<login-button>` appears


Scenario: Verify login to Trello with invalid password
When I click on element located by `<login-button>`
When I enter `<email>` in field located by `<email-field>`
When I click on element located by `<continue-button>`
When I wait until element located by `<password-field>` appears
When I enter `<invalid-password>` in field located by `<password-field>`
When I click on element located by `<login-submit-button>`
When I wait until element located by `By.xpath(//span[contains(text(), 'Incorrect email address and / or password')])` appears
