# Shopping Cart – vibe.d backend

OData V2 service (`/sap/opu/odata/IWBEP/EPM_DEVELOPER_SCENARIO_SRV/`) for the UI5 Shopping Cart app, written in D with vibe.d. It serves the data from `webapp/localService/mockdata`, the `$metadata`, and the `webapp` itself.

```sh
dub run            # http://localhost:8080/
PORT=9000 WEBAPP_DIR=../webapp dub run
```

Supported: `Products`, `ProductCategories`, `FeaturedProducts`, key access, navigation (`Products('X')/ProductCategory`, `ProductCategories('X')/Products`), `$filter` (eq/ne/lt/le/gt/ge, and/or/not, substringof/startswith/endswith), `$orderby`, `$top`, `$skip`, `$inlinecount`, `$expand`. Read-only.
