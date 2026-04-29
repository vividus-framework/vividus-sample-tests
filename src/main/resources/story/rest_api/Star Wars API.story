Description: Test demoing VIVIDUS capabilities for REST API

Scenario: Verify Luke's eyes are blue
When I execute HTTP GET request for resource with URL `https://swapi.info/api/people/1/`
Then `${responseCode}` is equal to `200`
Then JSON element value from `${response}` by JSON path `$.eye_color` is equal to `blue`
When I save JSON element value from `${response}` by JSON path `$.homeworld` to story variable `lukes-homeworld`
When I get JSON schema for resource `people` and validate JSON `${response}` against it

Scenario: Verify Luke's homeworld
When I execute HTTP GET request for resource with URL `${lukes-homeworld}`
Then `${responseCode}` is equal to `200`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `Tatooine`
When I get JSON schema for resource `planets` and validate JSON `${response}` against it
