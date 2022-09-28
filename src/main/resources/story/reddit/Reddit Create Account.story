Description: Test that create user account

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|search-input-field |By.fieldName(q)                 |
|search-button      |By.xpath((//*[@name='btnK'])[1])|

Scenario: Signing up a new user
Given I am on a page with the URL 'https://www.reddit.com/'
When I wait until element located `By.xpath(//a[@role="button"][text()="Sign Up"])` appears
When I click on element located `By.xpath(//a[@role="button"][text()="Sign Up"])`
When I click on element located `By.xpath(//input[@name="email"])`
When I enter `randomemail@randomemail123.com` in field located `By.xpath(//input[@id="regEmail"])`
