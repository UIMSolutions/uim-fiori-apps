module domain;

import std.datetime;
import uim.framework;

@safe:
// Domain Entity
struct TodoTask {
    string id;
    string title;
    string description;
    bool isCompleted;
    SysTime createdAt;
}

// Outbound Port: Interface für die Datenhaltung
interface TaskRepository {
    TodoTask[] findAll();
    TodoTask findById(string id);
    TodoTask save(TodoTask TodoTask);
    TodoTask update(string id, TodoTask TodoTask);
    void delete_(string id);
}

// Inbound Port: Anwendungsfall-Logik (Use Cases)
class TaskService {
    private TaskRepository repo;

    this(TaskRepository repo) {
        this.repo = repo;
    }

    TodoTask[] getAllTasks() {
        return repo.findAll();
    }

    TodoTask findById(string id) {
        return repo.findById(id);
    }

    TodoTask createTask(string title, string description) {
        import std.uuid : randomUUID;
        auto TodoTask = TodoTask(
            randomUUID().toString(),
            title,
            description,
            false,
            Clock.currTime()
        );
        return repo.save(TodoTask);
    }

    TodoTask updateTask(string id, string title, string description, bool isCompleted) {
        auto existing = repo.findById(id);
        existing.title = title;
        existing.description = description;
        existing.isCompleted = isCompleted;
        return repo.update(id, existing);
    }

    void deleteTask(string id) {
        repo.delete_(id);
    }
}

unittest {
    import domain;

    // Simple in-memory implementation of TaskRepository for testing
    class InMemoryTaskRepository : TaskRepository {
        private TodoTask[] tasks;

        TodoTask[] findAll() {
            return tasks;
        }

        TodoTask findById(string id) {
            foreach (t; tasks) {
                if (t.id == id) return t;
            }
            return TodoTask.init;
        }

        TodoTask save(TodoTask task) {
            tasks ~= task;
            return task;
        }

        TodoTask update(string id, TodoTask task) {
            foreach (i, t; tasks) {
                if (t.id == id) {
                    tasks[i] = task;
                    return task;
                }
            }
            return TodoTask.init;
        }

        void delete_(string id) {
            tasks = tasks.filter!(t => t.id != id).array;
        }
    }

    // Arrange
    auto service = new TaskService(new InMemoryTaskRepository());

    // Act
    auto task = service.createTask("Test Aufgabe", "Beschreibung");

    // Assert
    assert(task.title == "Test Aufgabe");
    assert(!task.isCompleted);

    // Test: Update auf completed
    auto updated = service.updateTask(task.id, task.title, task.description, true);
    assert(updated.isCompleted);
}