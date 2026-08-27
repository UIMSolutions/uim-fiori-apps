module uim.fiori.projectmanager.infrastructure.repositories.repository;

import uim.fiori.projectmanager;

@safe:

interface IProjectRepository {
    bool existsById(int id);

    Project[] findAll();

    Project findById(int projectId);

    void save(Project project);

    void update(Project project);

    void remove(Project project);

}

