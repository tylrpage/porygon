# API Design Decisions
1. Deck URL scheme, deck versions are their own top level url
    - Updating a deck version would be PUT /deck-versions/{deck_version_id}
    - Shallow nesting: collection operations like creating and listing will sit under the parent: decks
        - ex: POST /decks/{deck_id}/deck-versions
        - deck_id cannot change
    - Note: Authorizing changes to deck versions requires a query to decks for the userId
2. Security scheme: JWT
    - sheme: bearer and bearerFormat: JWT is a HTTP bearer auth mechanism where the token is passed as a json web token (JWT)
    - api requests include a token
    - A JWT is self contained (doesnt require a database lookup to verify) and signed (can check that is hasn't been altered)
        - It is split into 3 parts, header, payload, and signature
        - The JWT is verified by the server and contains the cognito_sub in in the payload which is translated into a user_id through a query
        - Since a JWT is only signed, not encrypted, it shouldn't contain any private information
    - user_id should never appear in a request, because it is not verifiable
    - user_id should never appear in a response, since it is not needed
3. PUT over PATCH
    - PUT replaces and entire resource while PATCH applies partial updates
    - With PUT, you represent a nullable field as a pointer, null means set to null and a value means set to that value, every edit requires updating the whole resource but it's okay because the resources are small and fully loaded
    - PATCH requires careful handeling because of Go's default zero values
    - A struct field in Go cannot tell between "not sent" and "send as nothing" because null fields default to 0 or empty string and a pointer field that is null and missing both turn into nil
    - With PATCH, explicitly setting a field to null (which we need to support) is difficult and requires a merge patch using a raw map or using a Nullable\[T\] type
4. Seperate GET /decks/{deck_id} and /decks/{deck_id}/deck-versions endpoints
    - /decks/{deck_id} gets data for deck, /decks/{deck_id}/deck-versions gets all the version data for a deck
    - It is simple and each endpoint does one thing
    - Each endpoint can be cached, /decks/{deck_id} can be cached while changes to versions happen
    - Deck summary page uses /decks and returns all the deck data, reusing the Deck schema
        - Doesn't need to return any deck_version data
5. Request schemas vs response schemas: seperate schemas
    - A response returns data containing server-assigned while a request does not
    - There are extra types but it is cleaner because all fields in the request schema will be writeable
    - A POST and PUT can share their request schemas
    - For example, deck_id is in DeckVersion but not DeckVersionInput, because requests using DeckVersionInput are not changing the deck_id, the deck_id would either be in the request url when creating a new version through POST or would be not needed when using PUT to modify a deck version through just the deck_version_id
6. Error format, what endpoints can have which errors
    - All requests could get a 401 if the user hasn't authenticated and has a missing/invalid/expired token, all data requests should require authentication
    - All requests involving an id could get a 404 if the user's derived id doesn't match the resource's user id or if the id doesn't exist, 403 would show somebody probing that the resource exists
        - "doesn't exist" and "not yours" should look identical
    - All requests could get a 400 if the user's request can't be understood by request-validation middleware
    - All POST and PUT requests could get a 422 if it gets past request-validation middleware but there is an issue with the request that the server catches, like an unknown id or invalid value
    - Requests to POST or PUT can 409 if the unique constraint can't be kept, such as duplicate names on archetypes, decks, and deck versions
    - Errors use RFC 9457 with mandatory title and status fields
        - Content-type: application/problem+json
        - type will be left out, meaning it is nothing more than the HTTP status
        - When a form has a field error, put it in a "invalid_params" extension member, this is an array of objects with a name (of the param) and reason (why it's invalid)
    - Unexpected (500) errors use OpenAPI's default response
7. We will have CRUD for archetypes, they are an important component of the deck and opponent match data
    - archetype icons are global and read only
    - GET /archetypes/{archetype_id} and GET /archetype-icons/{archetype_icon_id} are unecessary since all archetypes and icons will need to load in a picker anyways
8. id will be type integer, format int64 (matching bigint), when it gets to TS it will be number which can't go as high but it's high enough
9. No pagination needed for now, but response should be in an object containing a deck array so pagination can be supported later
10. Archetype and ArchetypeIcon will be referenced in containing schemas rather than embedded. Since they are nullable and OpenAPI has ugly support for nullable ref schemas.

# Cascades
- Deleting a user, deck, version, match, game cascasde to delete everything lower
- The user will need to be heavily warned about this
- Deleting an archetype doesn't cascade because archetypes can be null, but it will clear out the archetype data for decks and matches that had that archetype
- Users should be warned about deleting archetypes

# Paths
- /decks
- /decks/{deck_id}
- /decks/{deck_id}/deck-versions
- /deck-versions/{deck_version_id}
- /archetypes
- /archetype-icons

# Endpoints
- GET       /decks                                  -- Gets user's decks
- POST      /decks                                  -- Adds a new deck
- GET       /decks/{deck_id}                        -- Gets one deck
- PUT       /decks/{deck_id}                        -- Edits a deck
- DELETE    /decks/{deck_id}                        -- Deletes a deck
- GET       /decks/{deck_id}/deck-versions          -- Gets versions of a deck
- POST      /decks/{deck_id}/deck-versions          -- Adds version to deck
- GET       /deck-versions/{deck_version_id}        -- Gets version of a deck
- PUT       /deck-versions/{deck_version_id}        -- Edits version of a deck
- DELETE    /deck-versions/{deck_version_id}        -- Deletes a deck version
- GET       /archetypes                             -- Gets all user's archetypes
- POST      /archetypes                             -- Adds an archetype
- PUT       /archetypes/{archetype_id}              -- Edits an archetype
- DELETE    /archetypes/{archetype_id}              -- Deletes an archetype
- GET       /archetype-icons                        -- Gets all archetype icons

# Operation Ids
prefixes: get, replace, delete, list, create
suffixes: {schema name}