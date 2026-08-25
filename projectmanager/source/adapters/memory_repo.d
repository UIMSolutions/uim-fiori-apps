module adapters.memory_repo;

import domain;

@safe:

class InMemoryProjectRepository : ProjectRepository {
    private Project[int] projects;
    private int sequence = 0;

    override Project[] findAll() {
        return projects.values;
    }

    override bool tryFindById(int id, out Project project) {
        if (auto found = id in projects) {
            project = *found;
            return true;
        }
        return false;
    }

    override Project save(Project project) {
        projects[project.id] = project;
        if (project.id > sequence) {
            sequence = project.id;
        }
        return project;
    }

    override bool update(Project project) {
        if (project.id !in projects) {
            return false;
        }
        projects[project.id] = project;
        return true;
    }

    override bool deleteById(int id) {
        if (id !in projects) {
            return false;
        }
        projects.remove(id);
        return true;
    }

    override int nextId() {
        ++sequence;
        return sequence;
    }
}
