module uim.fiori_blocks.application.usecases.base;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageBaseUseCase : ManageBlockUseCase!BaseBlock {

  this(BaseRepository repository) {
    super(repository);
  }

  override BaseBlock createBlock(Json data) {
    // Implementation for creating a block
    auto block = new BaseBlock;
    // block.updateFromJson(data);
    // repository.save(block);
    return BaseBlock.fromJson(data);
  }

  override BaseBlock updateBlock(Json data) {
    // Implementation for updating a block
    if (!data.hasKey("ID"))
      return BaseBlock.init;

    auto block = repository.findById(data.getString("ID"));
    if (block.isNull)
      return BaseBlock.init;

    // block.updateFromJson(data);
    repository.save(block);
    return block;
  }

}