module uim.fiori_blocks.application.usecases.architecture;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageArchitectureUseCase : ManageBlockUseCase!ArchitectureBlock {
  this(ArchitectureRepository repository) {
    super(repository);
  }

  override ArchitectureBlock createBlock(Json data) {
    // Implementation for creating a block
    return ArchitectureBlock.fromJson(data);
  }
  
  override ArchitectureBlock updateBlock(Json data) {
    // Implementation for updating a block
    return ArchitectureBlock.fromJson(data);
  }

}
