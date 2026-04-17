Meta:
    @feature Add to Cart
    @priority 2

Scenario: Add Sauce Labs Bike Light to Cart
When I login to web app with username `${username}` and password `${password}`
Then text `Sauce Labs Bike Light` exists
Then number of elements found by `cssSelector([data-test="shopping-cart-badge"])` is equal to `0`
When I save text of element located by `xpath(//button[@data-test="add-to-cart-sauce-labs-bike-light"]/preceding-sibling::div[@data-test="inventory-item-price"])` to scenario variable `bike-light-price`
When I click on element located by `cssSelector([data-test="add-to-cart-sauce-labs-bike-light"])`
When I wait until element located by `cssSelector([data-test="shopping-cart-badge"])` contains text `1`
Then number of elements found by `cssSelector([data-test="remove-sauce-labs-bike-light"])` is equal to `1`
When I change context to element located by `cssSelector([data-test="remove-sauce-labs-bike-light"])`
Then context element has CSS property `color` with value that is_equal_to `rgb(226, 35, 26)`
When I reset context
When I click on element located by `cssSelector([data-test="shopping-cart-link"])`
When I wait until element located by `cssSelector([data-test="cart-list"])` appears
Then text `Sauce Labs Bike Light` exists
Then number of elements found by `cssSelector([data-test="shopping-cart-badge"])` is equal to `1`
Then text `${bike-light-price}` exists
