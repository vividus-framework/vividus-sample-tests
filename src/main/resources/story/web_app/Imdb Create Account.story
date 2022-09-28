Description: Test that create user account

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|search-input-field |By.fieldName(q)                 |
|search-button      |By.xpath((//*[@name='btnK'])[1])|

Scenario: Signing up a new user
Given I am on a page with the URL 'https://www.imdb.com/'
When I wait until element located `By.xpath(//div[@class="ipc-button__text"][text()="Sign In"])` appears
When I click on element located `By.xpath(//div[@class="ipc-button__text"][text()="Sign In"])`
When I wait until element located `By.xpath(//div[@class="list-group"]/a[text()="Create a New Account"])` appears
When I click on element located `By.xpath(//div[@class="list-group"]/a[text()="Create a New Account"])`
When I enter `Bob` in field located `By.xpath(//input[@name="customerName"])`
When I enter `myemailaddress@domainname123.com` in field located `By.xpath(//input[@name="email"])`
When I enter `randompassword123` in field located `By.xpath(//input[@name="password"])`
When I enter `randompassword123` in field located `By.xpath(//input[@name="passwordCheck"])`
When I click on element located `By.xpath(//input[@type="submit"])`
When I wait until element located `By.xpath(//a[@class="a-link-nav-icon"])` appears
!-- add the iframe
When I wait until element located `By.xpath(//div[@class="a-row a-spacing-mini"]/span[text()="Solve this puzzle to protect your account"])` appears
