Description: Test demoing VIVIDUS capabilities for Web Applications

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
|search-input-field |By.fieldName(q)                 |
|search-button      |By.xpath((//*[@name='btnK'])[1])|

Scenario: Verify VIVIDUS documentation is in Top 10 Google search results
Given I am on a page with the URL 'https://www.google.com/'
When I enter `VIVIDUS test automation` in field located `<search-input-field>`
When I wait until element located `<search-button>` appears
When I click on element located `<search-button>`
Then number of elements found by `linkUrlPart(https://docs.vividus.dev/vividus/)->filter.textPart(What is VIVIDUS :: VIVIDUS)` is equal to `1`
