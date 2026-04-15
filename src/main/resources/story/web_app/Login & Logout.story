Scenario: login
When I login to web app with username `${username}` and password `${password}`

Scenario: logout
When I click on element located by `id(react-burger-menu-btn)`
When I click on element located by `id(logout_sidebar_link)`
Then number of elements found by `id(login-button)` is equal to `1`
