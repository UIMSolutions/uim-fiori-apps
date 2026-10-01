# Requirements Management (Fiori 3 + OData V4 + vibe.d)

This project provides:
- SAP Fiori 3 UI5 app
- OData V4 backend implemented with `vibe.d`
- Docker packaging for one-command startup

## Features

- Create requirements
- Edit requirements
- Categorize requirements
- Delete requirements
- Print requirements
- Export requirements to CSV
- Business and Solution requirement types
- Business requirement can reference zero or many Solution requirements
- Solution requirement can reference zero or many child Solution requirements
- Every requirement belongs to a project

## Run with Docker

```bash
cd requirements
docker compose up --build
```

Open:
- App: `http://localhost:8080/`
- OData service root: `http://localhost:8080/odata/v4/RequirementsService/`
- OData metadata: `http://localhost:8080/odata/v4/RequirementsService/$metadata`

## Run locally without Docker

```bash
cd requirements/backend
dub run
```

## OData entity model

- `Projects`
  - `ID`, `Name`, `Description`
- `Requirements`
  - `ID`, `Title`, `Description`, `Category`, `Type`, `ProjectID`
  - `ParentBusinessRequirementID`
  - `ParentSolutionRequirementID`
  - `CreatedAt`, `UpdatedAt`
