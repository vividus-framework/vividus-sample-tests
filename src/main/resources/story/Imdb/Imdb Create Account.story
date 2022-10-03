Description: Test that create user account

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|search-input-field |By.fieldName(q)                 |
|search-button      |By.xpath((//*[@name='btnK'])[1])|

Scenario: Signing up a new user
Given I am on a page with the URL 'https://www.imdb.com/'
When I wait until element located `By.xpath(//*[@class="ipc-button__text"][text()="Sign In"])` appears
When I click on element located `By.xpath(//*[@class="ipc-button__text"][text()="Sign In"])`
When I wait until element located `By.xpath(//*[@class="list-group"]/a[text()="Create a New Account"])` appears
When I click on element located `By.xpath(//*[@class="list-group"]/a[text()="Create a New Account"])`
When I enter `#{generate(Name.firstName)}` in field located `By.xpath(//input[@name="customerName"])`
When I enter `#{generate(regexify '[a-z]{6}[A-Z]{2}')}@test.com` in field located `By.xpath(//input[@name="email"])`
When I enter `randompassword123` in field located `By.xpath(//input[@name="password"])`
When I enter `randompassword123` in field located `By.xpath(//input[@name="passwordCheck"])`
When I click on element located `By.xpath(//input[@type="submit"])`
When I wait until element located `By.xpath(//*[contains(@src, "logo")])` appears
When I wait until element located `By.xpath(//*[@id="cvf-aamation-challenge-iframe"])` appears
When I switch to frame located `By.xpath(//*[@id="cvf-aamation-challenge-iframe"])`
When I switch to frame located `By.xpath(//*[@id="aacb-arkose-frame"])`
When I switch to frame located `By.xpath(//*[@title="Verification challenge"])`
When I switch to frame located `By.xpath(//*[@id="fc-iframe-wrap"])`
When I switch to frame located `By.xpath(//*[@id="CaptchaFrame"])`
When I wait until element located `By.xpath(//*[@id="home_children_button"])` appears
When I click on all elements located `By.xpath(//*[@id="home_children_button"])`
