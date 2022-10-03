Description: Test that create user account

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|first-post         |By.xpath((//*[@data-testid="post-container" and .//@data-click-id="body"])[1])|

Scenario: Login in
Given I am on a page with the URL 'https://www.reddit.com/'
When I wait until element located `By.xpath(//a[@role="button"][text()="Log In"])` appears
When I click on element located `By.xpath(//a[@role="button"][text()="Log In"])`
When I switch to frame located `By.xpath(//*[contains(@src,"reddit.com/login")])`
When I wait until element located `By.xpath(//main//input[@id="loginUsername"])` appears
When I enter `New-Objective3067` in field located `By.xpath(//main//input[@id="loginUsername"])`
When I enter `ysj46329@cdfaq.com` in field located `By.xpath(//main//input[@id="loginPassword"])`
When I click on element located `By.xpath(//main//form[@action="/login"]//button[@type="submit"])`
When I wait until element located `By.xpath(//button[@id="USER_DROPDOWN_ID"]//span[text()="New-Objective3067"])` appears

Scenario: Search a post and open it page
When I enter `cute puppy` in field located `By.xpath(//input[@id="header-search-bar"])`
When I wait until element located `By.xpath(//*[@data-testid="search-trigger-item"])` appears
When I click on element located `By.xpath(//*[@data-testid="search-trigger-item"])`
When I wait until element located `By.xpath((//*[@data-testid="post-container" and .//*[@data-click-id="body"]])[1])` appears
When I click on element located `By.xpath((//*[@data-testid="post-container" and .//*[@data-click-id="body"]])[1])`
