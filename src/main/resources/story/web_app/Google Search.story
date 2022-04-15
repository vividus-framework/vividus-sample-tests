Description: Test demoing VIVIDUS capabilities for Web Applications

Scenario: Verify VIVIDUS documentation is in Top 10 Google search results
Given I am on a page with the URL 'https://www.google.com/'
When I enter `VIVIDUS` in field located `By.fieldName(q)`
When I click on element located `By.buttonName(btnK)`
Then number of elements found by `linkUrl(https://docs.vividus.dev/vividus/latest/index.html)` is equal to `1`
