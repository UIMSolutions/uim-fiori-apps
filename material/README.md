# Material Demo (Hexagonal)
Dieses Verzeichnis enthaelt eine kombinierte Loesung aus:
- SAPUI5/Fiori Frontend mit OData V4 Anbindung
- DLang/vibe.d Backend als OData V4 Service
- Hexagonaler Architektur im Backend (Domain, Application, Adapter)
- Auswahlbarer Persistenzadapter: InMemory, File, MongoDB
## Architektur
Backend in `backend/source/material_backend`:
- `domain/`: Fachobjekte und Domain-Service fuer Bestandsauswertung
- `application/`: Use-Case-orientierte Service-Schicht
- `adapters/inbound/http/`: OData HTTP Controller
- `adapters/outbound/inmemory/`: In-Memory Repository als Infrastrukturadapter
- `adapters/outbound/file/`: Dateibasierter Persistenzadapter (JSON)
- `adapters/outbound/mongodb/`: MongoDB Persistenzadapter
- `adapters/outbound/repository_factory.d`: Adapter-Auswahl per Umgebungsvariable
Frontend in `frontend/webapp`:
- OData V4 Modell in `manifest.json`
- `view/App.view.xml` als Material-Cockpit mit 4 Funktionsbereichen
- `controller/App.controller.js` fuer Create/Read Aktionen
## Abgedeckte Anforderungen
- Materialien anzeigen (`Materials`)
- Materialien erstellen (`POST Materials`)
- Materialien planen (`MaterialPlans`)
- Materialbestaende auswerten (`StockEvaluations`)
- Warenlager zuordnen und anzeigen (`WarehouseAssignments`, `Warehouses`)
## OData V4 Query-Optionen (Backend)
Unterstuetzt sind fuer die Collection-Endpunkte:
- Paging: `$top`, `$skip`
- Sortierung: `$orderby`
- Filter: `$filter` mit `and`/`or` und Klammern, plus `contains(...)`
- Expand:
  - `Materials?$expand=Assignments`
  - `Materials?$expand=Assignments($expand=Warehouse)`
  - `WarehouseAssignments?$expand=Warehouse`
- `@odata.nextLink` wird bei Paging automatisch ausgegeben
Beispiele:
```http
GET /odata/v4/material-service/Materials?$filter=contains(Name,'Schraube')&$orderby=TargetStock desc&$top=5
GET /odata/v4/material-service/StockEvaluations?$filter=Status eq 'CRITICAL'&$orderby=Available asc
GET /odata/v4/material-service/Materials?$expand=Assignments($expand=Warehouse)
GET /odata/v4/material-service/Materials?$filter=(TargetStock gt 1000 and contains(Name,'blech')) or ID eq 'M-1'&$top=1
```
## Start Backend
```bash
cd backend
dub run
```
Persistenzmodus waehlen:
```bash
# InMemory (Default)
export MATERIAL_PERSISTENCE=inmemory
# Datei-Adapter
export MATERIAL_PERSISTENCE=file
export MATERIAL_FILE_PATH=./data/material-store.json
# MongoDB-Adapter
export MATERIAL_PERSISTENCE=mongodb
export MATERIAL_MONGO_URI='mongodb://127.0.0.1:27017/?safe=true'
export MATERIAL_MONGO_DB=material_service
```
Backend URL:
- `http://localhost:8080/odata/v4/material-service/$metadata`
## Start Frontend
```bash
cd frontend
npm install
npm run start
```
UI5 Proxy leitet `/odata` automatisch auf `http://localhost:8080`.
## BTP Deployment-Artefakte
Folgende Dateien sind fuer Deployment vorbereitet:
- `mta.yaml`
- `xs-security.json`
- `approuter/xs-app.json`
- `approuter/package.json`
- `backend/manifest.yml`
- `frontend/manifest.yml`
Die MTA ist auf html5-repo Content Deployment gehaertet:
- `material-ui-deployer` (`com.sap.application.content`) deployed Frontend-Artefakte in `html5-apps-repo` host
- `material-destination-content` (`com.sap.application.content`) provisioniert Destinations inkl. Backend, html5 host und xsuaa token-exchange
- `material-approuter` nutzt `html5-apps-repo` runtime + destination service
Beispielablauf:
```bash
mbt build
cf deploy mta_archives/material-demo_1.0.0.mtar
```
