# SAP UI5 / Fiori + vibe.d (OData V4)

- `backend/` – vibe.d server: OData V4 service at `/odata/v4/shop/` (`$metadata`, `Products`, `Orders`; `$filter`, `$orderby`, `$top`, `$skip`, `$count`, `$select`, key access, and `POST`/`PATCH`/`PUT`/`DELETE` for create, update and delete; data is in memory and resets on restart) and static hosting of `webapp/`.
- `webapp/` – UI5 app (SAP Horizon, UI5 from the ui5.sap.com CDN): `sap.f.ShellBar`, a **Home** view with `sap.f.Card` cards, and **Products** / **Orders** views bound to the V4 model.

```sh
cd backend && dub run     # http://localhost:8080/   (PORT, WEBAPP_DIR configurable)
```

Products and Orders tables support multi-select. **Export** (CSV) and **Print** use the selected rows, or the complete list (current search and sort) if nothing is selected.
