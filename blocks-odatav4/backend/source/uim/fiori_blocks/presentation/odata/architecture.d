/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.architecture;

import uim.fiori_blocks;

@safe:

class ArchitectureOdataController : OdataController {
  protected ManageArchitectureUseCase useCase;

  this(ManageArchitectureUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    // router.post("/api/v1/architectures", &handleCreate);
    // router.get("/api/v1/architectures", &handleList);
    // router.get("/api/v1/architectures/*", &handleGet);
    // router.put("/api/v1/architectures/*", &handleUpdate);
    // router.delete_("/api/v1/architectures/*", &handleDelete);
  }
}