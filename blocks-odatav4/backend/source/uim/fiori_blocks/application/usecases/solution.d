module uim.fiori_blocks.application.usecases.solution;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageSolutionUseCase : ManageBlockUseCase!SolutionBlock {

  this(SolutionRepository repository) {
    super(repository);
  }

  override void createBlock(Json data) {
    // Implementation for creating a block
  }

  override void updateBlock(Json data) {
    // Implementation for updating a block
    if (!data.hasKey("ID"))
      return;

    auto block = repository.find(data.getString("ID"));
    if (block.isNull)
      return;
  }

}