module application;

import domain;

@safe:

// Inbound port (use case layer).
class ProjectService {
    private ProjectRepository repository;

    this(ProjectRepository repository) {
        this.repository = repository;
    }

    Project[] listProjects() {
        return repository.findAll();
    }

    bool getProject(int id, out Project project) {
        return repository.tryFindById(id, project);
    }

    Project createProject(string name, string description, Todo[] todos = []) {
        return repository.save(Project(
            repository.nextId(),
            name,
            description,
            todos.dup
        ));
    }

    bool updateProject(int id, string name, string description, Todo[] todos, out Project updated) {
        Project existing;
        if (!repository.tryFindById(id, existing)) {
            return false;
        }

        existing.name = name;
        existing.description = description;
        existing.todos = todos.dup;

        if (!repository.update(existing)) {
            return false;
        }

        updated = existing;
        return true;
    }

    bool deleteProject(int id) {
        return repository.deleteById(id);
    }
}
