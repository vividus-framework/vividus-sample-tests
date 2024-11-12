Scenario: Start VS code application
Given I start electron application

Scenario: Verify Get Started
When I wait `PT1M` until tab with title that is equal to `Walkthrough: Setup VS Code` appears and switch to it
Then number of elements found by `xpath(//title[text()='Walkthrough: Setup VS Code']):a` is = `1`
