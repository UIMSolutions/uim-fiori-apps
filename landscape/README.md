# IT-Bebauung: Application Landscape Map
Dieses Projekt liefert eine SAPUI5/Fiori App mit OData V4 Backend in DLang/vibe.d nach hexagonaler Architektur.
## Fachumfang
- Einstiegsseite (Overview):
  - Kachel 1: Karten-Ansicht als Matrix (Geschaeftsbereich x Prozessebene)
  - Kachel 2: Smart-Filter-Kachel (Kritikalitaet, Betriebsart, Lifecycle, Namenssuche)
  - Kachel 3: KPI Tag Cloud (Active, Decommissioning, Redundant)
- Detailseite (Object Page):
  - Stammdaten
  - Business & IT Owner
  - visuelle Schnittstellen-Netzwerkgrafik (Network Graph)
## Hexagonale Architektur
Backend in [backend/source/landscape_backend](backend/source/landscape_backend):
- domain: Entitaeten und Port-Interface
- application: Use-Case-Service
- adapters/inbound/http: OData V4 Controller
- adapters/outbound/inmemory: InMemory-Repository
## Lokaler Start
### Backend
```bash
cd backend
dub run
```
Service URL:
- <http://localhost:8081/odata/v4/landscape-service/>
### Frontend
```bash
cd frontend
npm install
npm run start
```
UI5 Proxy in [frontend/ui5.yaml](frontend/ui5.yaml) leitet `/odata` auf `http://localhost:8081`.
## OData Endpunkte
- `/odata/v4/landscape-service/`
- `/odata/v4/landscape-service/$metadata`
- `/odata/v4/landscape-service/Systems`
- `/odata/v4/landscape-service/Systems('<ID>')`
- `/odata/v4/landscape-service/Interfaces`
- `/odata/v4/landscape-service/MatrixCells`
- `/odata/v4/landscape-service/KPIOverview`
Unterstuetzt:
- `$filter` mit `and` / `or` / Klammern (auf Systems)
- `$orderby`
- `$top`, `$skip` + `@odata.nextLink`
## Deployment: SAP BTP Cloud Foundry
Dateien:
- [mta.yaml](mta.yaml)
- [xs-security.json](xs-security.json)
- [approuter/xs-app.json](approuter/xs-app.json)
Build & Deploy:
```bash
mbt build
cf deploy mta_archives/landscape-demo_1.0.0.mtar
```
## Deployment: Kubernetes
Artefakte:
- [Dockerfile.backend](Dockerfile.backend)
- [Dockerfile.frontend](Dockerfile.frontend)
- [k8s/backend-deployment.yaml](k8s/backend-deployment.yaml)
- [k8s/frontend-deployment.yaml](k8s/frontend-deployment.yaml)
- [k8s/ingress.yaml](k8s/ingress.yaml)
- [k8s/nginx.conf](k8s/nginx.conf)
Beispiel:
```bash
# 1) Backend binary bauen
cd backend
dub build
# 2) Frontend dist bauen
cd ../frontend
npm install
npm run build
# 3) Images bauen und pushen
docker build -f ../Dockerfile.backend -t your-registry/landscape-backend:1.0.0 ..
docker build -f ../Dockerfile.frontend -t your-registry/landscape-frontend:1.0.0 ..
docker push your-registry/landscape-backend:1.0.0
docker push your-registry/landscape-frontend:1.0.0
# 4) Image-Namen in k8s YAMLs anpassen und deployen
kubectl apply -f ../k8s/backend-deployment.yaml
kubectl apply -f ../k8s/frontend-deployment.yaml
kubectl apply -f ../k8s/ingress.yaml
```
