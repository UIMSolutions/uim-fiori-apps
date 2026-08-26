module uim.fiori.projectmanager.infrastructure.repositories.memory;

import uim.fiori.projectmanager;

@safe:

class MemoryProjectRepository {
    Project[int] _projects;

    bool existsById(int id) {
        return (id in _projects) ? true : false;
    }

    Project[] findAll() {
        return _projects.byValue.array;
    }

    Project findById(int projectId) {
        writeln("findById: ", projectId);
        return (existsById(projectId)) ? _projects[projectId] : Project.init;
    }

    void save(Project project) {
        _projects[project.id] = project;
    }

    void update(Project project) {
        if (existsById(project.id)) {
            _projects[project.id] = project;
        }
    }

    void remove(Project project) {
        _projects.remove(project.id);
    }
}

unittest {
    auto projectRepo = new MemoryProjectRepository();
    auto todoRepo = new TodoRepository();

    // Create a project
    auto project = Project(1, "Project 1", "Description 1", []);
    projectRepo.save(project);

    // Verify the project was saved
    assert(projectRepo.existsById(1));
    assert(projectRepo.findById(1).name == "Project 1");

    // Update the project
    project.name = "Updated Project 1";
    projectRepo.update(project);
    assert(projectRepo.findById(1).name == "Updated Project 1");

    // Remove the project
    projectRepo.remove(project);
    assert(!projectRepo.existsById(1));
}
