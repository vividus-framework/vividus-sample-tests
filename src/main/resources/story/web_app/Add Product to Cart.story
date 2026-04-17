Meta:
    @feature Add to Cart
    @priority 3

Scenario: Add Bolt T-Shirt to cart and verify it appears in cart

!-- Step 1: Log in
When I login to web app with username `${username}` and password `${password}`

!-- Step 2: Open details page for Bolt T-Shirt
When I wait until element located by `cssSelector([data-test="item-1-title-link"])` appears
When I click on element located by `cssSelector([data-test="item-1-title-link"])`

!-- Step 3: Verify details page is displayed
When I wait until element located by `id(back-to-products)` appears
Then text `Sauce Labs Bolt T-Shirt` exists

!-- Step 4: Click Add to cart
When I click on element located by `id(add-to-cart)`

!-- Step 5: Verify button changes to Remove
When I wait until element located by `id(remove)` appears

!-- Step 6: Verify cart badge shows 1
Then an element with the name 'shopping_cart_badge' and text '1' exists

!-- Step 7: Open cart
When I click on element located by `cssSelector([data-test="shopping-cart-link"])`

!-- Step 8: Verify Bolt T-Shirt is present in cart
When I wait until element located by `caseInsensitiveText(Your Cart)` appears
Then text `Sauce Labs Bolt T-Shirt` exists
