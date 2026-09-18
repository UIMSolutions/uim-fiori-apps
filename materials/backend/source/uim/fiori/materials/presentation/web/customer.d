module uim.fiori.materials.presentation.web.customer;

import uim.fiori;

@safe:

// Datenstruktur für das UI
struct Kunde {
    int id;
    string name;
    string status;
}

// class KundenService {
//     void zeigeDashboard(HTTPServerRequest req, HTTPServerResponse res) {
//         // Initiale Daten für die Seite
//         auto kunden = [
//             Kunde(1, "Muster AG", "Aktiv"),
//             Kunde(2, "Tech Corp", "Inaktiv")
//         ];
//         // Rendert das Template 'dashboard.dt' und übergibt die 'kunden'
//         res.render!("dashboard.dt", kunden);
//     }

//     // Dieser Endpunkt wird von htmx aufgerufen, um eine Tabellenzeile dynamisch zu laden
//     void ladeMehrKunden(HTTPServerRequest req, HTTPServerResponse res) {
//         auto neueKunden = [
//             Kunde(3, "Future Logistics", "Aktiv"),
//             Kunde(4, "Global Trade", "Aktiv")
//         ];
//         // Rendert NUR das Tabellen-Teilstück (Partial)
//         res.render!("kunden_zeilen.dt", neueKunden);
//     }
// }

class PortalController {
    // 1. Initialer Aufruf der Website (volles Layout)
    void index(HTTPServerRequest req, HTTPServerResponse res) {
        res.render!("dashboard.dt");
    }

    // 2. Dashboard-Endpunkt (sucht nach htmx-Request)
    void dashboard(HTTPServerRequest req, HTTPServerResponse res) {
        // Wenn der Request von htmx kommt, rendern wir NUR den Inhalt, ohne das Layout
        if ("HX-Request" in req.headers) {
            //     // Wir nutzen ein Inline-Diet-Fragment oder ein partial, um das Layout zu umgehen
            res.render!("dashboard_partial.dt");
        } else {
            res.render!("dashboard.dt");
        }
    }

    // 3. Kunden-Endpunkt (wird von htmx in #main-content geschossen)
    void kunden(HTTPServerRequest req, HTTPServerResponse res) {
        // Für den htmx-Sidebar-Klick reicht es, das reine Fragment auszuliefern
        res.render!("kunden.dt");
    }
}
