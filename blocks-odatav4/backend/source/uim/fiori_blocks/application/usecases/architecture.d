module uim.fiori_blocks.application.usecases.architecture;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageArchitectureUseCase : ManageBlockUseCase!ArchitectureBlock {
  this(ArchitectureRepository repository) {
    this._repository = repository;
  }

  void createBlock(Json data) {
    // Implementation for creating a block
  }

  void updateBlock(Json data) {
    // Implementation for updating a block
  }

}
