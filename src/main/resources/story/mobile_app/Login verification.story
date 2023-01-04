Scenario: Start the application
Given I start mobile application
When I open side menu
When I tap on element located by `accessibilityId(menu item log in)`


Scenario: User should be able to log in
When I type `bob@example.com` in field located `accessibilityId(Username input field)`
When I type `10203040` in field located `accessibilityId(Password input field)`
When I swipe up to element located by `accessibilityId(Login button)` with duration PT3S
When I tap on element located by `accessibilityId(Login button)`
!-- The locator is ugly to keep it work for both paltforms. (Element misses accessibility id)
When I wait until element located by `xpath(//*[@*="Products" and (local-name()="XCUIElementTypeStaticText" or local-name()="android.widget.TextView")])` appears
