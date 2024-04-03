Description: Test demoing VIVIDUS capabilities for Web Applications

Lifecycle:
Examples:
{transformer=FROM_LANDSCAPE}
| search-input-field | fieldName(q)                  |
| search-button      | xpath((//*[@name='btnK'])[1]) |

Scenario: Verify VIVIDUS documentation is in Top 10 Google search results
Given I am on page with URL `https://www.google.com/`
!-- Google doesn't have good ways to identify element: the second form refers to "Accept All" cookies action
When I find less than or equal to '1' elements by xpath(//button[@id='L2AGLb']) and for each element do
| step                                          |
| When I click on element located by `xpath(.)` |
When I enter `VIVIDUS test automation` in field located by `<search-input-field>`
When I wait until element located by `<search-button>` appears
When I click on element located by `<search-button>`
Then number of elements found by `linkUrlPart(https://docs.vividus.dev/vividus/)->filter.textPart(What is VIVIDUS :: VIVIDUS)` is equal to `1`
