module uim.fiori_blocks.application.usecases.architecture;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageArchitectureUseCase : ManageBlockUseCase!ArchitectureBlock {
  this(ArchitectureRepository repository) {
    super(repository);
  }

  override void createBlock(Json data) {
    // Implementation for creating a block
  }
  
  override void updateBlock(Json data) {
    // Implementation for updating a block
  }

}
