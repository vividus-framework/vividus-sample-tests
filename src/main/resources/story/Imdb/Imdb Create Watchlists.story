Description: Login into an existing user account. Go to the watchlist page and create new watchlists

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

Scenario: Go to the watchlist page and create new watchlists
When I click on element located `By.xpath(//a/*[text()="Watchlist"])`
When I wait until element located `By.xpath(//p[@class="seemore"])` appears
When I click on element located `By.xpath(//p[@class="seemore"])`
When I `5` times do:
|step																										|
|When I enter `#{generate(Cat.name)}` in field located `By.xpath(//*[@id="list-create-name"])`				|
|When I enter `#{generate(Hobbit.quote)}` in field located `By.xpath(//*[@id="list-create-description"])`	|
|When I click on element located `By.xpath(//button[text()="CREATE"])`										|
|When I click on element located `By.xpath(//*[text()="Done"])`												|
|When I click on element located `By.xpath(//*[text()="create a new list"])`								|

