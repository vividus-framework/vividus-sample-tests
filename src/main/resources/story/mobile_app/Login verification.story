Scenario: Start the application
Given I start mobile application
When I wait until element located `accessibilityId(test-Username)` appears

Scenario: User should be able to log in
When I type `standard_user` in field located `accessibilityId(test-Username)`
When I type `secret_sauce` in field located `accessibilityId(test-Password)`
When I tap on element located `accessibilityId(test-LOGIN)`
!-- The locator is ugly to keep it work for both paltforms. (Element misses accessibility id)
When I wait until element located `xpath(//*[@*="PRODUCTS" and (local-name()="XCUIElementTypeStaticText" or local-name()="android.widget.TextView")])` appears
