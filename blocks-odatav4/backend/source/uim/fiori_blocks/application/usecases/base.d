module uim.fiori_blocks.application.usecases.base;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageBaseUseCase : ManageBlockUseCase!BaseBlock {

  this(BaseRepository repository) {
    super(repository);
  }

  override void createBlock(Json data) {
    // Implementation for creating a block
  }

  override void updateBlock(Json data) {
    // Implementation for updating a block
    if (!data.hasKey("ID"))
      return;

    auto block = repository.findById(data.getString("ID"));
    if (block.isNull)
      return;
  }

}