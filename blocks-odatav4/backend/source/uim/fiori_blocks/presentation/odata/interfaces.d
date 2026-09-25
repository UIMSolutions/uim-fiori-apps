module uim.fiori_blocks.presentation.odata.interfaces;

import uim.fiori_blocks;

@safe:

class InterfaceOdataController : OdataController {
  protected ManageInterfaceUseCase useCase;

  this(ManageInterfaceUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    // router.post("/api/v1/interfaces", &handleCreate);
    // router.get("/api/v1/interfaces", &handleList);
    // router.get("/api/v1/interfaces/*", &handleGet);
    // router.put("/api/v1/interfaces/*", &handleUpdate);
    // router.delete_("/api/v1/interfaces/*", &handleDelete);
  }
}