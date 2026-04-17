Meta:
    @testCaseId TC-00001
    @requirementId REQ-00001
    @feature Inventory Sorting
    @priority 3

Scenario: Verify inventory sorting by Name Z to A
!-- [ASSUMPTION] Test case and requirement IDs were not provided, placeholder IDs are used and require validation.
When I login to web app with username `${username}` and password `${password}`
Then `#{extractPathFromUrl(${current-page-url})}` is equal to `/inventory.html`
When I select `Name (Z to A)` in dropdown located by `cssSelector([data-test='product-sort-container'])`
When I change context to element located by `cssSelector([data-test='active-option'])`
Then text `Name (Z to A)` exists
When I change context to element located by `cssSelector([data-test='inventory-list'] > [data-test='inventory-item']:first-child)`
Then text `Test.allTheThings() T-Shirt (Red)` exists
When I change context to element located by `cssSelector([data-test='inventory-list'] > [data-test='inventory-item']:last-child)`
Then text `Sauce Labs Backpack` exists
When I reset context
Then number of elements found by `cssSelector([data-test='inventory-list'])` is equal to `1`
Then `#{extractPathFromUrl(${current-page-url})}` is equal to `/inventory.html`
