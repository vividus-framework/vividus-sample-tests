Meta:
    @feature Add to Cart
    @priority 3

Scenario: Add Bolt T-Shirt to cart and verify it appears in cart
When I login to web app with username `${username}` and password `${password}`
When I click on element located by `cssSelector([data-test="item-1-title-link"])`
When I wait until element located by `id(back-to-products)` appears
Then `${current-page-url}` matches `.+/inventory-item\.html\?id=1`
When I click on element located by `id(add-to-cart)`
Then number of elements found by `id(remove)` is equal to `1`
When I save text of element located by `cssSelector([data-test="shopping-cart-badge"])` to scenario variable `cartBadgeText`
Then `${cartBadgeText}` is equal to `1`
When I click on element located by `cssSelector([data-test="shopping-cart-link"])`
When I wait until element located by `cssSelector([data-test="cart-list"])` appears
Then `${current-page-url}` matches `.+/cart\.html`
Then text `Sauce Labs Bolt T-Shirt` exists
