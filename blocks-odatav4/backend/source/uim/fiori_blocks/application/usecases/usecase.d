module uim.fiori_blocks.application.usecases.usecase;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageBlockUseCase(T) {
  protected Repository!T _repository;

  this(Repository!T repository) {
    this._repository = repository;
  }

    void createBlock(Json data) {
      // Implementation for creating a block
    }

    bool hasBlock(string id) {
      // Implementation for checking if a block exists
      if (repository is null)
        return false;

      return repository.existsById(id);
    }

    bool hasAllBlocks(string[] ids) {
      // Implementation for checking if all of the blocks exist
      if (repository is null)
        return false;

      return repository.existsAllId(ids);
    }

    bool hasAnyBlock(string[] ids) {
      // Implementation for checking if any of the blocks exist
      if (repository is null)
        return false;

      return repository.existsAnyId(ids);
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

    void updateBlock(Json data) {
      // Implementation for updating a block
      if (!data.hasKey("ID")) return;

      auto block = repository.findById(data["ID"]);

    }

    void updateBlocks(Json[] data) {
      // Implementation for updating multiple blocks
      data.each!(d => updateBlock(d));
    }

    void deleteBlock(string id) {
      // Implementation for deleting a block
      if (repository is null)
        return;

      repository.removeById(id);
    }
}