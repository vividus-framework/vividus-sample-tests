Description: Test that create user account

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|search-input-field |By.fieldName(q)                 |
|search-button      |By.xpath((//*[@name='btnK'])[1])|

Scenario: Signing up a new user
Given I am on a page with the URL 'https://www.walmart.com/'
When I wait until element located `By.xpath(//input[@data-automation-id="header-input-search"])` appears
When I enter `Froot Loops Mega Size//n` in field located `By.xpath(//input[@data-automation-id="header-input-search"])`
When I click on element located `By.xpath(//div[@data-automation-id="headerSignIn"])`
