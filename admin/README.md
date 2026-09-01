# Admin Client (vibe.d + SAP Fiori + OData)

This folder contains a typical admin application split into backend and frontend modules, prepared for Cloud Foundry deployment.

## Project layout

- `backend`: vibe.d service exposing OData-style endpoints
- `frontend`: SAP Fiori (UI5) app served via SAP Approuter
- `mta.yaml`: multi-target app descriptor for CF upload
- `xs-security.json`: XSUAA configuration

## Backend API

Base path: `/odata/v4/admin`

- `GET /$metadata`
- `GET /Users`
- `POST /Users`
- `GET /Users/<id>`
- `PUT /Users/<id>`
- `DELETE /Users/<id>`

## Local development

1. Start backend

```bash
cd backend
dub run
```

1. Start frontend

```bash
cd frontend
npm install
npm run start:local
```

The UI5 dev server proxies `/odata` to `http://localhost:8080/odata`.

## Cloud Foundry deployment

1. Build MTAR (requires MBT):

```bash
mbt build -p=cf
```

1. Deploy:

```bash
cf deploy mta_archives/admin-client_1.0.0.mtar
```

## Notes

- The backend keeps user data in memory for now; replace `UserRepository` with DB persistence later.
- The app uses XSUAA routes in approuter (`authenticationType: xsuaa`).
