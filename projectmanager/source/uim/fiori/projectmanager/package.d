module uim.fiori.projectmanager;

public:
    import uim.framework;

    import uim.fiori;
    import uim.fiori.projectmanager.application;
    import uim.fiori.projectmanager.domain;
    import uim.fiori.projectmanager.helpers;
    import uim.fiori.projectmanager.infrastructure;
    import uim.fiori.projectmanager.presentation;

// In-Memory-Datenbank & ID-Zähler
int nextProjectId = 3;
int nextTodoId = 301;