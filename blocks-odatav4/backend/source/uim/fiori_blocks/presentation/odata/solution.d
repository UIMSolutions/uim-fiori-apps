module uim.fiori_blocks.presentation.odata.solution;

import uim.fiori_blocks;
import uim.fiori_blocks.application.usecases.solution;

mixin(ShowModule!());

@safe:
class SolutionController {
  protected ManageSolutionUseCase useCase;

  this(ManageSolutionUseCase useCase) {
    this.useCase = useCase;
  }

  void registerRoutes(URLRouter router) {
    // router.post("/api/v1/configs", &handleCreate);
    // router.get("/api/v1/configs", &handleList);
    // router.get("/api/v1/configs/*", &handleGet);
    // router.put("/api/v1/configs/*", &handleUpdate);
    // router.delete_("/api/v1/configs/*", &handleDelete);
  }
}