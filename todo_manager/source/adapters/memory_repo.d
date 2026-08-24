module adapters.memory_repo;

import domain;
import std.exception : enforce;

@safe:

// In-Memory Implementierung des Outbound Ports
class InMemoryTaskRepository : TaskRepository {
    private TodoTask[string] tasks;

    override TodoTask[] findAll() {
        return tasks.values;
    }

    override TodoTask findById(string id) {
        enforce(id in tasks, "TodoTask nicht gefunden");
        return tasks[id];
    }

    override TodoTask save(TodoTask TodoTask) {
        tasks[TodoTask.id] = TodoTask;
        return TodoTask;
    }

    override TodoTask update(string id, TodoTask TodoTask) {
        enforce(id in tasks, "TodoTask nicht gefunden");
        tasks[id] = TodoTask;
        return TodoTask;
    }

    override void delete_(string id) {
        tasks.remove(id);
    }
}
