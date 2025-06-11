Scenario: Start VS code application
Given I start electron application
When I wait `PT1M` until tab with title that is equal to `` appears and switch to it
When I wait until number of elements located by `xpath(//a[contains(., 'Restricted Mode')]):a` is equal to 1
