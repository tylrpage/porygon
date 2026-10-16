# Backend Design Decisions
1. Project Layout, Go module will be in api/ to keep things organized against other things like the React app
    - Module path: github.com/tylrpage/porygon/api
    - cmd/: holds subfolders for each binary
        - porygon-api/: api server
        - archetype-icon-seed/: seeds archetype icons
    - internal/: holds files private to the module, contains oapi-codegen (internal/api) and sqlc output (internal/db)
    - ../db/migrations not being in the go module means we can't use go:embed on them and ship it in the go module binary, but this is fine for the moment
2. oapi-codegen strict server, strict-server will be enabled, because the OAD already lists all the possible responses, strict will be a safe and less boilerplate-y choice. The drawback to not using plain is we lose access to *http.Request, which contains header data, we need auth from the header, so will be processed by our auth middleware first.
    - std-http-server (net/http) will be the router layer that strict-server is layered on top of. Before Go 1.22 you needed a router library for path parameters, but now it is supported in Go. The other features are not needed and net/http is a good fundamental server to start with
    - Typed responses for expected errors, return err for unexpected ones, ResponseErrorHandlerFunc logs it and sends a generic 500
3. emit_pointers_for_null_types enabled on sqlc so that nullable ids are *int64 from both codegen outputs
    - similarly, sqlc needs to be told to generate timestamptz as time.Time to match oapi-codegen
4. Before Cognito auth is setup, we will use a dev-only header that isn't processed in the production environment using an environment variable AUTH_MODE=dev (defaulted to off).
    - Auth middleware will upsert user_id on every request into content.Context
    - the dev header will be dev_user_id
5. Ownership checks should be in the SQL query, so lack of ownership comes back as an empty query result so "not yours" comes back as "doesn't exist"
    - Requests to deck versions always require a join to their corresponding deck to check for ownership
    - POST and PUT to decks needs to check that the archetype_id belongs to the user by querying for the archetype and checking the user_id, if it is invalid then return 422 since the archetype_id is invalid
6. When mapping postgres errors to http statuses, we will use a table that maps from constraint name to field name to populate the ProblemDetails.invalid_params
7. Testing
    - Database testing using separate porygon_test database
    - A fresh user will be used per test, with a unique cognito_sub
    - Testing it done through http requests using httptest, to test full router, auth, validation, and handler stack