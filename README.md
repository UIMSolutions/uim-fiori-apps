# uim-fiori-apps

A small D library for SAP Fiori apps in D, with optional vibe.d JSON support.

## Features

- Build a base `manifest.json` structure for SAP Fiori apps
- Validate required app descriptor fields
- Export manifest content as JSON text
- Enable vibe.d JSON backend with `-version=HaveVibeD`

## Build and test

```bash
dub build
dub test
```

## Usage

```d
import uim_fiori_apps;

auto jsonText = buildManifestJson(FioriAppConfig(
    "com.example.app",
    "Example App",
    "Example SAP Fiori application"
));
```