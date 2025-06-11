Description: Test demoing VIVIDUS capabilities for Web Applications

Scenario: Test login
Given I am on page with URL `https://the-internet.herokuapp.com/login`
Then text `Login Page` exists
When I enter `tomsmith` in field located by `fieldName(username)`
When I enter `SuperSecretPassword!` in field located by `fieldName(password)`
When I click on element located by `buttonName(submit)`
Then text `You logged into a secure area!` exists
