module uim.fiori.projectmanager.infrastructure.repositories.file;

import uim.fiori.projectmanager;

import std.array : array;
import std.file : exists, readText, write;
import std.stdio : writeln;
import vibe.data.json : parseJsonString, serializeToJson, deserializeJson, Json;

@safe:

class FileProjectRepository {
    private string _filePath;
    private Project[int] _projects;

    this(string filePath = "/tmp/projects.json") {
        _filePath = filePath;

        import std.path : dirName;
        import std.file : mkdirRecurse, exists;

        string dir = dirName(_filePath);
        if (dir.length > 0 && !exists(dir)) {
            mkdirRecurse(dir);
        }

        load();
    }

    private void load() {
        if (exists(_filePath)) {
            try {
                string text = readText(_filePath);
                if (text.length > 0) {
                    Json j = parseJsonString(text);
                    Project[] list = deserializeJson!(Project[])(j);
                    _projects.clear();
                    foreach (p; list) {
                        _projects[p.id] = p;
                    }
                }
            } catch (Exception e) {
                writeln("Fehler beim Laden der Datei ", _filePath, ": ", e.msg);
            }
        }
    }

    private void saveToDisk() {
        try {
            Json j = serializeToJson(_projects.byValue.array);
            write(_filePath, j.toPrettyString());
        } catch (Exception e) {
            writeln("Fehler beim Speichern in Datei ", _filePath, ": ", e.msg);
        }
    }

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
        saveToDisk();
    }

    void update(Project project) {
        if (existsById(project.id)) {
            _projects[project.id] = project;
            saveToDisk();
        }
    }

    void remove(Project project) {
        if (existsById(project.id)) {
            _projects.remove(project.id);
            saveToDisk();
        }
    }
}

unittest {
    import std.file : remove;

    string testFile = "test_projects.json";
    if (exists(testFile)) remove(testFile);

    scope(exit) {
        if (exists(testFile)) remove(testFile);
    }

    auto projectRepo = new FileProjectRepository(testFile);

    // Create a project
    auto project = Project(1, "Project 1", "Description 1", []);
    projectRepo.save(project);

    // Verify the project was saved in memory & on disk
    assert(projectRepo.existsById(1));
    assert(projectRepo.findById(1).name == "Project 1");

    // Test persistence across instances
    auto newRepoInstance = new FileProjectRepository(testFile);
    assert(newRepoInstance.existsById(1));
    assert(newRepoInstance.findById(1).name == "Project 1");

    // Update the project
    project.name = "Updated Project 1";
    projectRepo.update(project);
    assert(projectRepo.findById(1).name == "Updated Project 1");

    // Remove the project
    projectRepo.remove(project);
    assert(!projectRepo.existsById(1));
}