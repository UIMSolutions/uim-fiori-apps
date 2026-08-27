module uim.fiori.projectmanager.application.usecases.todo;

import uim.fiori.projectmanager;

@safe:

class TodoUseCase {
    private IProjectRepository projectRepository;
    private TodoRepository todoRepository;

    this(IProjectRepository projectRepository, TodoRepository todoRepository) {
        this.projectRepository = projectRepository;
        this.todoRepository = todoRepository;
    }

    public void createTodo(int projectId, string description) {
        auto project = projectRepository.findById(projectId);
        if (project == Project.init) {
            throw new Exception("Project not found");
        }
        auto todo = Todo(nextTodoId++, description, false);
        project.todos ~= todo;
        projectRepository.update(project);
    }

    public void deleteTodo(int projectId, int todoId) {
        auto project = projectRepository.findById(projectId);
        if (project == Project.init) {
            throw new Exception("Project not found");
        }

        foreach (i, ref todo; project.todos) {
            if (todo.id == todoId) {
                project.todos.remove(i);
                projectRepository.update(project);
                return;
            }
        }
    }
}

unittest {
    auto projectRepo = new FileProjectRepository();
    auto todoRepo = new TodoRepository();
    auto usecase = new TodoUseCase(projectRepo, todoRepo);

    // Create a project
    auto project = Project(1, "Project 1", "Description 1", []);
    projectRepo.save(project);

    // Create a todo
    // usecase.createTodo(1, "Test Todo");
    // assert(projectRepo.findById(1).todos.length == 1);  

    // // Delete the todo
    // usecase.deleteTodo(1, 1);
    // assert(projectRepo.findById(1).todos.length == 0);
}