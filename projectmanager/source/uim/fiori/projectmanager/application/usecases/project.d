module uim.fiori.projectmanager.application.usecases.project;

import uim.fiori.projectmanager;

@safe:

class ProjectUseCase {
    private ProjectRepository projectRepository;
    private TodoRepository todoRepository;

    this(ProjectRepository projectRepository, TodoRepository todoRepository) {
        this.projectRepository = projectRepository;
        this.todoRepository = todoRepository;
    }

    Project[] listProjects() {
        return projectRepository.findAll();
    }

    Project getProject(int id) {
        return projectRepository.findById(id);
    }

    void createProject(string name, string description, Todo[] todos) {
        auto project = Project(nextProjectId++, name, description, todos);
        projectRepository.save(project);
    }

    bool updateProject(int id, string name, string description, Todo[] todos) {
        auto project = projectRepository.findById(id);
        if (project == Project.init) return false;
        
        project.name = name;
        project.description = description;
        project.todos = todos;
        projectRepository.update(project);
        return true;
    }

    bool deleteProject(int id) {
        auto project = projectRepository.findById(id);
        if (project == Project.init) return false;

        projectRepository.remove(project);
        return true;
    }
}

unittest {
    auto projectRepo = new ProjectRepository();
    auto todoRepo = new TodoRepository();
    auto usecase = new ProjectUseCase(projectRepo, todoRepo);

    // Create a project
    usecase.createProject("Project 1", "Description 1", []);
    assert(projectRepo.existsById(1));

    // List projects
    auto projects = usecase.listProjects();
    assert(projects.length == 1);

    // Get project
    auto project = usecase.getProject(1);
    assert(project.name == "Project 1");    

    // Update project
    bool updated = usecase.updateProject(1, "Updated Project 1", "Updated Description 1", []);
    assert(updated);
    project = usecase.getProject(1);
    assert(project.name == "Updated Project 1");    

    // Delete project
    bool deleted = usecase.deleteProject(1);
    assert(deleted);
    assert(!projectRepo.existsById(1));
}   