/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.composition;

/// Composition root: the only place that knows all concrete implementations and wires
/// configuration -> storage -> repositories -> use cases -> catalog.
import uim.fiori_blocks.application;
import uim.fiori_blocks.domain.entities;
import uim.fiori_blocks.infrastructure;
import uim.fiori_blocks.persistence;
import uim.fiori_blocks.ports;

@safe:

final class AppContext {
  AppConfig config;
  IDocumentStorage storage;
  ServiceCatalog catalog;
  IAuthenticator authenticator;
}

AppContext bootstrap(AppConfig config) {
  configureLogging(config.logLevel);

  auto context = new AppContext;
  context.config = config;
  context.storage = createStorage(config);
  context.catalog = new ServiceCatalog;
  context.authenticator = new DemoAuthenticator(config.demoPassword);

  static foreach (E; AllEntities) {
    context.catalog.register(new EntitySetService!E(
        new ManageEntitiesUseCase!E(
        new DocumentRepository!E(context.storage, E.entitySet, seedFor!E))));
  }

  logDiagnostic("Storage: %s, entity sets: %s", context.storage.describe, context.catalog.names);
  return context;
}

IDocumentStorage createStorage(const ref AppConfig config) {
  final switch (config.storage) {
  case StorageKind.memory:
    return new MemoryDocumentStorage;
  case StorageKind.file:
    return new JsonFileDocumentStorage(config.dataDir);
  }
}
