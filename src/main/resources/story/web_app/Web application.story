Description: Test demoing VIVIDUS capabilities for Web Applications

Scenario: Verify VIVIDUS documentation is in Top 10 DuckDuckGo search results
Given I am on page with URL `https://duckduckgo.com/`
When I enter `VIVIDUS test automation` in field located by `fieldName(Search without being tracked)`
When I click on element located by `buttonName(Search)`
Then number of elements found by `linkUrlPart(https://docs.vividus.dev/vividus/)->filter.textPart(What is VIVIDUS :: VIVIDUS)` is equal to `1`
