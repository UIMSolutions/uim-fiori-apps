module uim.fiori_blocks.application.usecases.interface_;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageInterfaceUseCase : ManageBlockUseCase!InterfaceBlock {
  
  this(InterfaceRepository repository) {
    super(repository);
  }

  override void createBlock(Json data) {
    // Implementation for creating a block
  }

  override void updateBlock(Json data) {
    // Implementation for updating a block
  }

}