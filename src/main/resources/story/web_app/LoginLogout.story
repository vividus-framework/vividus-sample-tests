Description: Trello login/logout test

Lifecycle:
Examples:
/story/input/input.table


Scenario: Verify that user can login to trello with valid creds
When I login with email `kadixah655@ridteam.com` and password `TRELLO@123456789!`


Scenario: Verify that user can log out of trello
When I log out

Scenario: Verify that user can not log in to trello with invalid email
When I fill in email `kadixah655@ridteam.com` and wait for password field to appear
When I enter `TRELLO@123456789` in field located by `<password-input-field>`
When I click on element located by `<login-button>`
When I wait until element located by `<error-message>` appears