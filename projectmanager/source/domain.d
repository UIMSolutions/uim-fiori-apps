module domain;

@safe:

struct Todo {
    int id;
    string title;
    bool completed;
}

struct Project {
    int id;
    string name;
    string description;
    Todo[] todos;
}

// Outbound port: persistence contract.
interface ProjectRepository {
    Project[] findAll();
    bool tryFindById(int id, out Project project);
    Project save(Project project);
    bool update(Project project);
    bool deleteById(int id);
    int nextId();
}
