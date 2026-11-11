# blocks-odatav4 – EA Building Blocks Manager

SAP Fiori 3 / UI5 app for maintaining enterprise architecture building blocks (base, architecture, solution and interface blocks, users).
The backend is a D / vibe.d 0.10.3 service built with hexagonal (Clean) Architecture. It exposes the same application core through four adapters:

| Adapter | Module | Purpose |
|---|---|---|
| **OData v4** | `presentation/odata` | `$metadata`, CRUD, query options, `$batch` for the Fiori frontend |
| **HTTP** | `presentation/http` | Login, notifications, log history, `/health`, static frontend |
| **CLI** | `presentation/cli` | Start the server or GUI, CRUD, import/export, metadata |
| **GtkD GUI** | `presentation/gui` | Desktop client (`desktop` build configuration only) |

## Directory layout

```
blocks-odatav4/
├── mta.yaml                 MTA descriptor (backend + approuter + XSUAA)
├── manifest.yml             direct cf push without approuter (deploy-cf.sh)
├── backend/
│   ├── dub.sdl              configurations: server (default), desktop (+GtkD)
│   ├── config/default.json  local defaults (file storage in backend/data)
│   └── source/uim/fiori_blocks/
│       ├── domain/          entities, enumerations, exceptions, services (validation, ids)
│       ├── ports/           repositories, storages, usecases, services (interfaces only)
│       ├── application/     usecases (generic CRUD), services (catalog, query), dtos
│       ├── infrastructure/  configuration, logging, security, serialization
│       ├── persistence/     repositories, storages (memory / JSON files), mappers
│       ├── presentation/    odata, http, cli, gui
│       └── composition.d    composition root (wires everything)
├── frontend/                UI5 app (view/, controller/, i18n/, localService/)
└── approuter/               @sap/approuter, xs-app.json, xs-security.json
```

Dependencies point inwards: `presentation → application → domain`. `persistence` and `infrastructure` implement the ports. Only `composition.d` knows the concrete classes.

## Build & run

```sh
cd backend
dub build                       # server + CLI      -> ./blocks-odatav4
dub build --config=desktop      # + GtkD GUI        -> ./blocks-odatav4-desktop (needs GTK 3)
dub test                        # unit + end-to-end tests

./blocks-odatav4                # = serve, http://127.0.0.1:8080/  (Fiori app, login admin / Welcome1!)
./blocks-odatav4-desktop gui    # desktop client on the same data directory
./blocks-odatav4 --help
```

### CLI examples

```sh
./blocks-odatav4 sets
./blocks-odatav4 list ArchitectureBlocks --select ID,Name,Version
./blocks-odatav4 list BaseBlocks --filter "DependsOn/any(d:d/Criticality eq 'High')" -f json
./blocks-odatav4 create InterfaceBlocks --data '{"Name":"Kafka Topic","Status":"Planned"}'
./blocks-odatav4 update Users USR-003 --data '{"Active":true}'
./blocks-odatav4 delete InterfaceBlocks IF-03
./blocks-odatav4 export -o backup.json && ./blocks-odatav4 import --file backup.json
./blocks-odatav4 metadata -o ../frontend/localService/metadata.xml
```

The CLI, the GUI and the server share the JSON files in `backend/data/` when `storage` is `file`. A running server keeps its data in memory and reads the files only at startup. Restart it after changing data with the CLI.

## Configuration

Values are applied in this order, later ones win: compiled defaults → `config/default.json` (or `--config`) → environment → `VCAP_SERVICES` → command line options.

| Option | Environment | CLI | Default |
|---|---|---|---|
| port | `PORT` (CF; also binds 0.0.0.0) | `--port` | 8080 |
| bindAddresses | `BLOCKS_BIND` | `--bind` | 127.0.0.1, ::1 |
| publicDir | `BLOCKS_PUBLIC_DIR` | `--public-dir` | ../frontend |
| storage (`memory`/`file`) | `BLOCKS_STORAGE` | `--storage` | memory (file in default.json) |
| dataDir | `BLOCKS_DATA_DIR` | `--data-dir` | data |
| logLevel | `BLOCKS_LOG_LEVEL` | `--log-level` | info |
| cors | `BLOCKS_CORS` | – | true |
| demoPassword | `BLOCKS_DEMO_PASSWORD` | – | Welcome1! |

On Cloud Foundry, the credentials of a user-provided service named `blocks-config` override all other sources:
`cf cups blocks-config -p '{"logLevel":"debug"}'`.

## OData v4 service (`/odata/v4/`)

- `$metadata` is generated from the domain structs. `Dependency` is a ComplexType, and collections are `Collection(...)`.
- Entity sets: `BaseBlocks`, `ArchitectureBlocks`, `SolutionBlocks`, `InterfaceBlocks`, `Users`.
- Supported requests:
  - `GET Set`, `GET Set('id')`, `GET Set('id')/Prop`, `GET Set/$count`
  - `POST` (201 + `Location`), `PATCH`, `PUT`, `DELETE` (204)
  - `Prefer: return=minimal`
- Query options:
  - `$filter`: `eq ne gt ge lt le and or not in`, `contains startswith endswith indexof concat tolower toupper trim length substring`, lambdas `any`/`all`
  - `$select`, `$orderby`, `$top`, `$skip`, `$count`, `$search`
- `$batch` accepts multipart/mixed (as sent by the UI5 v4 ODataModel) and JSON:
  - Changesets and atomicity groups run as transactions. A failed changeset is rolled back completely.
  - `Content-ID` references (`$1`) are supported.
- Errors use the OData format `{"error":{"code","message"}}`:
  - 400: validation or syntax errors
  - 404: entity or entity set not found
  - 409: duplicate key

## Deployment (SAP BTP, Cloud Foundry)

```sh
mbt build && cf deploy mta_archives/blocks-odatav4_2.0.0.mtar   # backend + approuter + XSUAA
./deploy-cf.sh                                                 # backend only (manifest.yml)
```

`mta.yaml` runs `deploy-cf.sh --build`. This compiles a cflinuxfs4 binary with ldc2 in Docker and copies the frontend to `cf-dist/public`. The approuter authenticates against XSUAA (`xs-security.json`, roles *Viewer* and *Administrator*) and forwards requests with the JWT to the backend.

To run the approuter locally, enter the XSUAA service key in `approuter/default-env.json` (git-ignored), then run `npm install && npm start`.

## Known limitations

- The login view uses `DemoAuthenticator` (users `admin` / `viewer`, password from the configuration). The backend does not validate XSUAA JWTs yet. On BTP, protection comes from the approuter only.
- The file storage is meant for one writer process at a time. Writes are atomic, but there is no locking between processes.
- `$expand` is accepted and ignored, because the model has no navigation properties (complex types are always returned inline).
- `/api/logs` and `/api/notifications` return demo content.
