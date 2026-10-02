# SAP Fiori 3 Launchpad Sample (UI5 + vibe.d OData V4)

This project contains:

- `backend`: vibe.d HTTP service exposing a lightweight OData V4 endpoint
- `frontend`: SAPUI5 app with a Fiori 3 style launchpad shell and routed views

## Features

- OData V4 service root: `/odata/v4/launchpad/`
- OData V4 metadata: `/odata/v4/launchpad/$metadata`
- Example entity set with CRUD: `/odata/v4/launchpad/Products`
- Entity by key: `/odata/v4/launchpad/Products('P-1000')`
- Launchpad-style navigation views:
- Home tile navigation to Products, Reports and Settings
- SAP BTP CF deployment descriptors: `mta.yaml`, `xs-security.json`, `approuter/xs-app.json`

## Run backend

```bash
cd backend
dub run
```

Backend starts on `http://localhost:8080` by default.

## Run frontend

```bash
cd frontend
npm install
npm start
```

UI5 proxy routes `/odata` to `http://localhost:8080`.

## Cloud Foundry deployment

```bash
mbt build
cf deploy mta_archives/launchpad-demo_1.0.0.mtar
```
