Meta:
    @feature Product Details
    @priority 3

Scenario: Login to web application
Given I initialize story variable `inventoryPageUrl` with value `/inventory.html`
When I login to web app with username `${username}` and password `${password}`

Scenario: Verify first product on inventory page
When I wait until element located by `cssSelector([data-test='inventory-item-name'])` appears
When I save text of element located by `cssSelector([data-test='inventory-item-name'])->filter.index(1)` to story variable `productName`
When I save text of element located by `cssSelector([data-test='inventory-item-price'])->filter.index(1)` to story variable `productPrice`

Scenario: Verify product details page
When I click on element located by `cssSelector([data-test*='title-link'])->filter.index(1)`
When I wait until element located by `cssSelector([data-test='inventory-item-name'])` appears
When I save text of element located by `cssSelector([data-test='inventory-item-name'])` to story variable `detailsProductName`
When I save text of element located by `cssSelector([data-test='inventory-item-price'])` to story variable `detailsProductPrice`
Then `${detailsProductName}` is equal_to `${productName}`
Then `${detailsProductPrice}` is equal_to `${productPrice}`
Then number of elements found by `cssSelector([data-test='inventory-item-desc'])` is equal_to `1`

Scenario: Return to inventory page
When I click on element located by `cssSelector([data-test='back-to-products'])`
When I wait until element located by `cssSelector([data-test='title'])` appears
Then the page has the relative URL '${inventoryPageUrl}'
