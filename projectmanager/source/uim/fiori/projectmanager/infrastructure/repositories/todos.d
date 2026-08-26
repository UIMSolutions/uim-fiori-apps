module uim.fiori.projectmanager.infrastructure.repositories.todos;

import uim.fiori.projectmanager;

@safe:

class TodoRepository {
    Todo[int] _todos;

    bool existsById(int id) {
        return (id in _todos) ? true : false;
    }

    Todo[] findAll() {
        return _todos.byValue.array;
    }

    Todo findById(int id) {
        return existsById(id) ? _todos[id] : Todo.init;
    }

    void save(Todo todo) {
        _todos[todo.id] = todo;
    }

    void update(Todo todo) {
        if (existsById(todo.id)) {
            _todos[todo.id] = todo;
        }
    }

    void remove(Todo todo) {
        _todos.remove(todo.id);
    }
}

unittest {
    auto todoRepo = new TodoRepository();

    // Create a todo
    auto todo = Todo(1, "Test Todo", false);
    todoRepo.save(todo);

    // Verify the todo was saved
    assert(todoRepo.existsById(1));
    assert(todoRepo.findById(1).title == "Test Todo");  

    // Update the todo
    todo.title = "Updated Test Todo";
    todoRepo.update(todo);
    assert(todoRepo.findById(1).title == "Updated Test Todo");  

    // Remove the todo
    todoRepo.remove(todo);
    assert(!todoRepo.existsById(1));
}