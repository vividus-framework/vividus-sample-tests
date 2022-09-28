Description: Login into an existing user account. Add a movie into a Watchlist,sort the Watchlist and Export it.
Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|search-input-field |By.fieldName(q)                 |
|search-button      |By.xpath((//*[@name='btnK'])[1])|

Scenario: Login in
Given I am on a page with the URL 'https://www.imdb.com/'
When I wait until element located `By.xpath(//div[@class="ipc-button__text"][text()="Sign In"])` appears
When I click on element located `By.xpath(//div[@class="ipc-button__text"][text()="Sign In"])`
When I wait until element located `By.xpath(//span[@class="auth-provider-text"][text()="Sign in with IMDb"])` appears
When I click on element located `By.xpath(//span[@class="auth-provider-text"][text()="Sign in with IMDb"])`
When I enter `wry74954@nezid.com` in field located `By.xpath(//input[@name="email"])`
When I enter `wry74954@nezid.com` in field located `By.xpath(//input[@name="password"])`
When I click on element located `By.xpath(//input[@type="submit"])`

Scenario: Search a movie and add it to watchlist
When I enter `Interstellar` in field located `By.xpath(//input[@id="suggestion-search"])`
When I wait until element located `By.xpath(//li[@id="react-autowhatever-1--item-0"]/a/div/div[text()="Interstellar"])` appears
When I click on element located `By.xpath(//li[@id="react-autowhatever-1--item-0"]/a/div/div[text()="Interstellar"])`
When I wait until element located `By.xpath(//div/h1[@data-testid="hero-title-block__title"][text()="Interstellar"])` appears
When I click on element located `By.xpath(//button[@data-testid="tm-box-wl-button"])`
When I wait until element located `By.xpath(//button[@data-testid="tm-box-wl-button"]/div[text()="In Watchlist"])` appears

Scenario: Export watchlist and remove first movie from watchlist
When I click on element located `By.xpath(//a/div[text()="Watchlist"])`
When I wait until element located `By.xpath(//h1[text()="Your Watchlist"])` appears
When I select `Release Date` in dropdown located `By.xpath(//div[@id="main"]//select[@id="lister-sort-by-options"])`
When I click on element located `By.xpath(//div[@class="export"]/a[text()="Export this list"])`
When I click on element located `By.xpath(//div[@title="Click to remove from watchlist"])`
When I wait until element located `By.xpath(//div[@title="Click to add to watchlist"])` appears
