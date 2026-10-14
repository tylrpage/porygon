# Random Learnings
1. Schema vs Object vs Type
    - In the context of api-design.md
    - Schema: The definition of what valid data looks like
    - Object: A JSON *value* in curly braces
    - Type: In Go or TS, it's a language construct. Codegen turns a schema into a Go type for example
2. URI stands for Uniform Resource Identifier which just means text that identifies some resource on the web
    - For example, a URL is a URI, and so is something like "urn:isbn:978-3-16-148410-0" identifying a particular book
3. Problem Details (RFC 9457)
    - A standardized way to communicate error details in an HTTP response
    - Object memebers
        - type: URI identifying the problem's type
        - status: matches the HTTP status code, for convenience
        - title: short human readable summary of the problem type
            - ex: "You do not have enough credit."
        - detail: short human readable explanation specific to this occurance
            - ex: "Your current balance is 30, but taht costs 50."
        - instance: URI that references the specific instance of the problem
        - more members, specific to the problem type, can be preset, these are "extension members"
    - Generic problems don't need new problem types, for example there is no need for a "write access disallowed" problem type when the 403 forbidden code exists
    - You should also be careful not to expose attack vectors by reavealing implementation internals through the error messages
4. Next time, I would use Open API 3.1 instead of 3.0.3 for nullable referenced schemas. Claude chose 3.0.3 because it thought oapi-codegen didn't support 3.1 but it does.