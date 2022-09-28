Description: Test that create user account

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|search-input-field |By.fieldName(q)                 |
|search-button      |By.xpath((//*[@name='btnK'])[1])|

Scenario: Signing up a new user
Given I am on a page with the URL 'https://www.walmart.com/'
When I wait until element located `By.xpath(//div[@data-automation-id="headerSignIn"])` appears
When I click on element located `By.xpath(//div[@data-automation-id="headerSignIn"])`
When I click on element located `By.xpath(//button[@data-automation-id="header-create-account"])`
When I wait until element located `By.xpath(//input[@name="firstName"])` appears
When I enter `Bob` in field located `By.xpath(//input[@name="firstName"]`
