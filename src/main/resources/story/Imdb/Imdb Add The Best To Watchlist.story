Description: Login into an existing user account. Go to the best fantasy movies and add att 8+ rating movies to the watchlist

Scenario: Login in
Given I am on a page with the URL 'https://www.imdb.com/'
When I wait until element located `By.xpath(//div[@class="ipc-button__text"][text()="Sign In"])` appears
When I click on element located `By.xpath(//div[@class="ipc-button__text"][text()="Sign In"])`
When I wait until element located `By.xpath(//span[@class="auth-provider-text"][text()="Sign in with IMDb"])` appears
When I execute steps:
|step																										|
|When I click on element located `By.xpath(//span[@class="auth-provider-text"][text()="Sign in with IMDb"])`|
|When I enter `wry74954@nezid.com` in field located `By.xpath(//input[@name="email"])`						|
|When I enter `wry74954@nezid.com` in field located `By.xpath(//input[@name="password"])`					|
|When I click on element located `By.xpath(//input[@type="submit"])`										|

Scenario: Go to the best fantasy movies and add at 8+ rating movies to the watchlist
When I click on element located `By.xpath(//*[text()="Menu"])`
When I click on all elements located `By.xpath(//*[@role="menuitem"]//*[text()="Browse Movies by Genre"])`
When I wait until element located `By.xpath(//*[@title="Fantasy"])` appears
When I click on element located `By.xpath(//*[@title="Fantasy"])`
When I find >= `1` elements by `By.xpath(//*[contains(@*,"ratings-imdb-rating") and @data-value>=8])` and for each element do
|step																				|
|When I click on element located `By.xpath(//*[@title="Click to add to watchlist"])`|
When I click on element located `By.xpath(//*[text()="Watchlist"])`
When I wait until element located `By.xpath(//*[text()="Your Watchlist"])` appears

