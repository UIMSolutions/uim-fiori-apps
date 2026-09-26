module uim.fiori_blocks.application.usecases.interface_;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageInterfaceUseCase : ManageBlockUseCase!InterfaceBlock {
  
  this(InterfaceRepository repository) {
    super(repository);
  }

  override InterfaceBlock createBlock(Json data) {
    // Implementation for creating a block

    auto block = InterfaceBlock();
    // block.updateFromJson(data);
    // repository.save(block);
    return block;
  }

  override InterfaceBlock updateBlock(Json data) {
    // Implementation for updating a block
    if (!data.hasKey("ID"))
      return InterfaceBlock.init;

    auto block = repository.findById(data.getString("ID"));
    if (block.isNull)
      return InterfaceBlock.init;

    // block.updateFromJson(data);
    repository.save(block);
    return block;
  }

}