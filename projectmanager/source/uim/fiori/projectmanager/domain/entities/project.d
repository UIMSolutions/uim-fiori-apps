module uim.fiori.projectmanager.domain.entities.project;

import uim.fiori.projectmanager;

@safe:
struct Project {
    int id;
    string name;
    string description;
    Todo[] todos;
}