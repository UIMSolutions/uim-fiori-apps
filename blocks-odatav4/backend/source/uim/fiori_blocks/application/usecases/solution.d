module uim.fiori_blocks.application.usecases.solution;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageSolutionUseCase : ManageBlockUseCase!SolutionBlock {

  this(SolutionRepository repository) {
    super(repository);
  }

  override SolutionBlock createBlock(Json data) {
    // Implementation for creating a block
    auto block = SolutionBlock();
    // block.updateFromJson(data);
    // repository.save(block);
    return SolutionBlock.fromJson(data);
  }

  override SolutionBlock updateBlock(Json data) {
    // Implementation for updating a block
    if (!data.hasKey("ID"))
      return SolutionBlock.init;

    auto block = repository.findById(data.getString("ID"));
    if (block.isNull)
      return SolutionBlock.init;

    // block.updateFromJson(data);
    repository.save(block);
    return block;
  }

}