import vibe.d;
import uim.fiori_project;

@safe:
// Data Transfer Objects (DTOs) für SAPUI5 Controls

struct MicroChartData {
    int actualPercent;
    double budgetSpent;
    double budgetTotal;
}

struct ProcessNode {
    string id;
    string laneId;
    string title;
    string state; // Positive, Critical, Negative, Neutral
    string[] children;
}

struct ProcessLane {
    string id;
    string icon;
    string label;
    int position;
}

struct ProcessFlowData {
    ProcessLane[] lanes;
    ProcessNode[] nodes;
}

struct NetworkNode {
    string key;
    string title;
    string group;
    string status; // Success, Warning, Error
}

struct NetworkLine {
    string from;
    string to;
    string status;
}

struct NetworkGraphData {
    NetworkNode[] nodes;
    NetworkLine[] lines;
}

struct GanttTask {
    string id;
    string name;
    string startTime; // Format: YYYYMMDDHHmmss
    string endTime;
    string completion;
}

struct GanttOrder {
    string id;
    string name;
    GanttTask[] tasks;
}

struct ProjectDashboardPayload {
    MicroChartData metrics;
    ProcessFlowData processFlow;
    NetworkGraphData networkGraph;
    GanttOrder[] ganttOrders;
}

// REST Interface Contract
@path("/api/v1")
interface IPMBackendAPI {
    @path("/project/dashboard")
    ProjectDashboardPayload getDashboardData();
}

// REST Implementation
class PMBackendAPI : IPMBackendAPI {
    override ProjectDashboardPayload getDashboardData() {
        ProjectDashboardPayload data;

        // 1. MicroChart Data
        data.metrics = MicroChartData(78, 420000.0, 550000.0);

        // 2. ProcessFlow Data
        data.processFlow.lanes = [
            ProcessLane("0", "sap-icon://edit", "Initialisierung", 0),
            ProcessLane("1", "sap-icon://action", "Durchführung", 1),
            ProcessLane("2", "sap-icon://accept", "Abschluss", 2)
        ];

        data.processFlow.nodes = [
            ProcessNode("1", "0", "Kick-off Approved", "Positive", ["2"]),
            ProcessNode("2", "1", "Sprint 1-4 Sprint-Goal", "Positive", ["3", "4"]),
            ProcessNode("3", "1", "Architektur-Review", "Critical", ["5"]),
            ProcessNode("4", "1", "Qualitätssicherung", "Neutral", ["5"]),
            ProcessNode("5", "2", "Go-Live Freigabe", "Neutral", [])
        ];

        // 3. NetworkGraph Data
        data.networkGraph.nodes = [
            NetworkNode("N1", "Backend API (vibe.d)", "Core", "Success"),
            NetworkNode("N2", "UI5 Frontend", "UI", "Success"),
            NetworkNode("N3", "Database Connector", "DB", "Warning"),
            NetworkNode("N4", "Authentication XSUAA", "Security", "Success")
        ];

        data.networkGraph.lines = [
            NetworkLine("N2", "N1", "Success"),
            NetworkLine("N1", "N3", "Warning"),
            NetworkLine("N1", "N4", "Success")
        ];

        // 4. Gantt Data (GanttChartWithTable erwartet spezifische Datumsformate)
        GanttTask t1 = GanttTask("T1", "Setup vibe.d Server", "20261001000000", "20261010000000", "100%");
        GanttTask t2 = GanttTask("T2", "Implement OData/REST", "20261011000000", "20261025000000", "60%");
        GanttOrder o1 = GanttOrder("O1", "Phase 1: Backend", [t1, t2]);

        GanttTask t3 = GanttTask("T3", "UI5 Gantt Integration", "20261020000000", "20261115000000", "30%");
        GanttOrder o2 = GanttOrder("O2", "Phase 2: Frontend", [t3]);

        data.ganttOrders = [o1, o2];

        return data;
    }
}

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8085;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;

    // Registrierung der REST API
    router.registerRestInterface(new PMBackendAPI());

    // Statisches File Server Routing für die SAPUI5 Frontend Assets
    auto view = new PMMainView("/view/Mail.view.xml");
    view.registerRoutes(router);
    router.get("*", serveStaticFiles("public/"));

    logInfo("Server läuft unter http://127.0.0.1:8085/");
    listenHTTP(settings, router);
    runApplication();
}
