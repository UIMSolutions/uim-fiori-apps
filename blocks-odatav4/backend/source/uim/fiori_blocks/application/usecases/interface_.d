module uim.fiori_blocks.application.usecases.interface_;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageInterfaceUseCase {
  
  this(InterfaceRepository repository) {
    this._repository = repository;
  }

  void createBlock(Json data) {
    // Implementation for creating a block
  }

  void updateBlock(Json data) {
    // Implementation for updating a block
  }

}