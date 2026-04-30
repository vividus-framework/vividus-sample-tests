Description: Test demoing VIVIDUS capabilities for Web Applications
Scenario: Test login
Given I am on page with URL `https://the-internet.herokuapp.com/login`
Then text `Login Page` exists
When I login to web app with username `tomsmith` and password `SuperSecretPassword!`
Then text `You logged into a secure area!` exists

Scenario: Test another login
Given I initialize scenario variable `username` with value `#{generate(Credentials.username)}`
Given I am on page with URL `https://uitestingplayground.com/sampleapp`
Then text `Sample App` exists
When I login to web app with username `${username}` and password `pwd`
Then text `Welcome, ${username}!` exists
