module uim.fiori_blocks.application.usecases.usecase;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageBlockUseCase(T) {

  this(BlockRepository!T repository) {
    this._repository = repository;
  }


  protected BlockRepository!T _repository;
  BlockRepository!T repository() {
    return this._repository;
  }

  void repository(BlockRepository!T repository) {
    this._repository = repository;
  }

    T createBlock(Json data) {
      // Implementation for creating a block
      // auto block = new T;
      // block.updateFromJson(data);
      // repository.save(block);
      return T.init;
    }

    bool hasBlock(string id) {
      // Implementation for checking if a block exists
      if (repository is null)
        return false;

      return repository.exists(id);
    }

    bool hasAllBlocks(string[] ids) {
      // Implementation for checking if all of the blocks exist
      if (repository is null)
        return false;

      return repository.existsAll(ids);
    }

    bool hasAnyBlock(string[] ids) {
      // Implementation for checking if any of the blocks exist
      if (repository is null)
        return false;

      return repository.existsAny(ids);
    }

    // Implementation for getting the exported block
    T getBlock(string id) {
      if (repository is null)
        return T.init;

      return repository.findById(id);
    }

    T[] listBlocks() {
      // Implementation for getting all exported blocks
      if (repository is null)
        return null;

      return repository.findAll();
    }

    T updateBlock(Json data) {
      // Implementation for updating a block
      // if (!data.hasKey("ID")) return T.init;

      // auto block = repository.findById(data.getString("ID"));
      // if (block.isNull) return T.init;

      // // block.updateFromJson(data);
      // repository.save(block);
      // return block;
      return T.init;
    }

    void updateBlocks(Json[] data) {
      // Implementation for updating multiple blocks
      data.each!(d => updateBlock(d));
    }

    void deleteBlock(string id) {
      // Implementation for deleting a block
      if (repository is null)
        return;

      repository.remove(id);
    }
}