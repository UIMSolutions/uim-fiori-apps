/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.base;

import uim.fiori_blocks;
import uim.fiori_blocks.application.usecases.solution;

mixin(ShowModule!());

@safe:
class BaseController : OdataController {
  protected ManageBaseUseCase useCase;

  this(ManageBaseUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    // router.post("/api/v1/configs", &handleCreate);
    // router.get("/api/v1/configs", &handleList);
    // router.get("/api/v1/configs/*", &handleGet);
    // router.put("/api/v1/configs/*", &handleUpdate);
    // router.delete_("/api/v1/configs/*", &handleDelete);
  }
}