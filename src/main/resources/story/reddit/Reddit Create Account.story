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
When I switch to frame located `By.xpath(//*[contains(@src,"reddit.com/register")])`
When I enter `#{generate(regexify '[a-z]{6}[A-Z]{2}')}@test.com` in field located `By.xpath(//input[@id="regEmail"])`
When I click on element located `By.xpath(//*[@data-step="email"][text()="Continue"])`
When I wait until element located `By.xpath(//*[@class="Onboarding__usernameWrapper"])` appears
When I click on element located `By.xpath(//*[@class="Onboarding__usernameSuggestion"][2])`
When I enter `password123.` in field located `By.xpath(//*[@id="regPassword"])`
When I enter `password123.` in field located `By.xpath(//*[@id="regPassword"])`
When I click on element located `By.xpath(//*[@data-step="username-and-password"][text()="Sign Up"])`
!-- Ends on captcha
