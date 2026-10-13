# Porygon
Porygon is a web app that helps you track your Pokemon TCG decks and their match history.

This app is a way for me to learn new web technologies through doing. It is an app I myself want to use and I think other Pokemon TCG players would enjoy.

# Stack
- DB: Postgres 17, goose migrations, hosted on Neon
- Contract Layer: OpenAPI 3.0
- Backend: Go API server, running in Docker container on AWS Lambda
- Frontend: React, TypeScript, Vite build tool, TanStack Query for managing data in React, hosted on S3 + CloudFront
- Auth: Cognito

# Status
The project is very much **incomplete** and still in active development
## Done
- Defined feature set and implementation milestone plan (see /plans/milestones.md)
- Data model design and migration complete (see /db/migrations/00001_init.sql)
- API design design complete (see /plans/api-design.md)
- First GET and POST endpoints described in Open API Description file (see /openapi/openapi.yaml)
## To Do
- API endpoint description YAML
- Go backend deck CRUD API
- React frontend for managing decks
- Go backend match CRUD API
- React frontend for recording matches
- Light analytics, view win rate and tag rate by opponent archetype and deck version
- Battle log parser, auto fill game result info by pasting PTCG Live battlelog
- Deployment, Go API as a container on AWS Lambda, React app on S3 + CloudFront, Postgres on Neon, login through Cognito
- CI/CD, GitHub Actions deploying to AWS

# AI Use
- Every line of every file is written by me, unless explicitly stated otherwise in the file
- AI could probably create this project in 30 minutes, but I believe learning is a result of time and effort spent working through problems
- On the other hand, I am trying to complete this project in a timely fashion while being exposed to a lot of new technologies, syntaxes, and patterns. To help focus my learning on information that is directly relevant to this project I use Claude Code
- Claude is instructed that this is a learning project and that I want to learn by doing, as a result it avoids giving me direct answers and instead directs me to documentation resources, provides examples, points out errors in my understanding, and tells me what decisions I need to think through
- I think there is also value in learning about the wrong things: accidentally reading documentation for the wrong system, learning about a database or library you decide not to use, or dechipering a confusing syntax error through google. But I think for this project, my current approach is the best way to balance time spent

# Planned Feature Set
- In Porygon, decks are represented as multiple versions of your exact 60 cards, helping you to track tweaks made to your deck and how they perform.
- Decks are assigned a deck archetype, something to identify the semi-specific type of deck you are playing, ex: "Dragapult" or "Mega Lucario". Matches represent one or more games against an opponent (think Bo1, Bo3, etc). Deck archetypes are assigned a name and 1-2 icons, similar to [decks on limitlesstcg.com](https://limitlesstcg.com/decks)
- A match records what deck version you were playing and what deck archetype your opponent played. You can record information about the game like who won, who went first, tags, and notes. The app is flexible to the user's needs, letting you define your own tags and deck archetypes. Each game records who won, as well as optional data like who won the coin flip. Games can also be tagged, ex: "Bricked", "Decked Out"
- If the game was played on PTCG Live, you can copy and paste the battlelog text and all game information that can be derived from the battle log will be auto filled into the game data
- Light analytics will allow you to view win rate and tag rates by deck version and opponent deck archetype
- The web app aims to be customizable and flexible, letting the user track what they want to. This is goal is supported by user defined deck archetypes, match environments, and tags. There are also notes fields on decks, deck versions, matches, and games.