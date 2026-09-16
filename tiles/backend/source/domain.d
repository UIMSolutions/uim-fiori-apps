module domain;
import uim.fiori;
@safe:
struct TileItem {
    string id;
    string icon;
    string type;
    string number;
    string numberUnit;
    string title;
    string info;
    string infoState;
    string description;
    Json toJson() const {
        Json obj = Json.emptyObject;
        obj["ID"] = Json(id);
        obj["Icon"] = Json(icon);
        obj["Type"] = Json(type);
        obj["Number"] = Json(number);
        obj["NumberUnit"] = Json(numberUnit);
        obj["Title"] = Json(title);
        obj["Info"] = Json(info);
        obj["Description"] = Json(description);
        obj["InfoState"] = Json(infoState.length ? infoState : "None");
        return obj;
    }
}