Scenario: Start VS code application
Given I start electron application

Scenario: Verify Get Started
When I wait `PT1M` until window with title that is equal to `Get Started` appears and switch to it
Then number of elements found by `xpath(//title[text()='Get Started']):a` is = `1`
