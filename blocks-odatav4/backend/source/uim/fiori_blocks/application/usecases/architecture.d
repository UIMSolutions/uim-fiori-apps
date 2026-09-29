module uim.fiori_blocks.application.usecases.architecture;

import uim.fiori_blocks;

mixin(ShowModule!());

@safe:
class ManageArchitectureUseCase : ManageBlockUseCase!ArchitectureBlock {
  this(ArchitectureRepository repository) {
    super(repository);
  }

  override ArchitectureBlock createBlock(Json data) {
    auto block = ArchitectureBlock.fromJson(data);
    block.ID = data.getString("ID", randomUUID().toString);

    block.DependsOn = data.getArray("DependsOn").map!(item => Dependency.fromJson(item)).array;
    return block;
  }
  
  override ArchitectureBlock updateBlock(Json data) {
    auto block = ArchitectureBlock.fromJson(data);
    block.Name = data.getString("Name", block.Name);
    block.Responsible = data.getString("Responsible", block.Responsible);
    block.Version = data.getString("Version", block.Version);
    block.Modul = data.getString("Modul", block.Modul);
    block.Service = data.getString("Service", block.Service);
    block.Product = data.getString("Product", block.Product);
    block.Date = data.getString("Date", block.Date);
    block.Description = data.getString("Description", block.Description);
    block.AdditionalInfo = data.getString("AdditionalInfo", block.AdditionalInfo);

    block.DependsOn = data.getArray("DependsOn").map!(item => Dependency.fromJson(item)).array;
    return block;
  }

}
