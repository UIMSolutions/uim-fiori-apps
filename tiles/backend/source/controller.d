module controller;
import uim.fiori;
import domain;
import std.string : endsWith, indexOf;
import std.conv : to;
@safe:
private TileItem[] buildTiles() {
    TileItem[] tiles;
    tiles ~= TileItem(
        "T1",
        "sap-icon://hint",
        "Monitor",
        "",
        "",
        "Tiles: modern UI design",
        "Design update available",
        "Information",
        "Tile design and usage recommendations"
    );
    tiles ~= TileItem(
        "T2",
        "sap-icon://inbox",
        "",
        "89",
        "",
        "Approve Leave Requests",
        "Overdue",
        "Error",
        "Open leave approvals that require action"
    );
    tiles ~= TileItem(
        "T3",
        "sap-icon://travel-expense-report",
        "",
        "281",
        "EUR",
        "Travel Reimbursement",
        "1 day ago",
        "Warning",
        "Recently submitted travel expenses"
    );
    tiles ~= TileItem(
        "T4",
        "sap-icon://cart",
        "",
        "787",
        "EUR",
        "My Shopping Carts",
        "Waiting for Approval",
        "Success",
        "Carts pending purchasing approval"
    );
    return tiles;
}
void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
    immutable xml = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="TileService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Tile">
        <Key>
          <PropertyRef Name="ID" />
        </Key>
        <Property Name="ID" Type="Edm.String" Nullable="false" />
        <Property Name="Icon" Type="Edm.String" />
        <Property Name="Type" Type="Edm.String" />
        <Property Name="Number" Type="Edm.String" />
        <Property Name="NumberUnit" Type="Edm.String" />
        <Property Name="Title" Type="Edm.String" />
        <Property Name="Info" Type="Edm.String" />
        <Property Name="InfoState" Type="Edm.String" />
        <Property Name="Description" Type="Edm.String" />
      </EntityType>
      <EntityContainer Name="Container">
        <EntitySet Name="Tiles" EntityType="TileService.Tile" />
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
    res.headers["OData-Version"] = "4.0";
    res.contentType = "application/xml";
    res.writeBody(xml);
}
void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
    Json values = Json.emptyArray;
    Json tiles = Json.emptyObject;
    tiles["name"] = Json("Tiles");
    tiles["kind"] = Json("EntitySet");
    tiles["url"] = Json("Tiles");
    values.appendArrayElement(tiles);
    Json response = Json.emptyObject;
    response["@odata.context"] = Json("/odata/v4/TileService/$metadata");
    response["value"] = values;
    res.headers["OData-Version"] = "4.0";
    res.contentType = "application/json; charset=utf-8";
    res.writeJsonBody(response);
}
void getTiles(HTTPServerRequest req, HTTPServerResponse res) {
    auto path = req.requestPath.to!string;
    if (path.endsWith("/Tiles")) {
        Json value = Json.emptyArray;
        foreach (tile; buildTiles()) {
            value.appendArrayElement(tile.toJson());
        }
        Json response = Json.emptyObject;
        response["@odata.context"] = Json("/odata/v4/TileService/$metadata#Tiles");
        response["value"] = value;
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json; charset=utf-8";
        res.writeJsonBody(response);
        return;
    }
    immutable marker = "/Tiles(";
    auto idx = indexOf(path, marker);
    if (idx < 0 || !path.endsWith(")")) {
        res.statusCode = HTTPStatus.badRequest;
        res.headers["OData-Version"] = "4.0";
        res.contentType = "application/json; charset=utf-8";
        res.writeJsonBody(Json.emptyObject);
        return;
    }
    auto rawKey = path[idx + cast(ptrdiff_t) marker.length .. $ - 1];
    string key = rawKey;
    if (rawKey.length >= 2 && rawKey[0] == '\'' && rawKey[$ - 1] == '\'') {
        key = rawKey[1 .. $ - 1];
    }
    foreach (tile; buildTiles()) {
        if (tile.id == key) {
            Json response = tile.toJson();
            response["@odata.context"] = Json("/odata/v4/TileService/$metadata#Tiles/$entity");
            res.headers["OData-Version"] = "4.0";
            res.contentType = "application/json; charset=utf-8";
            res.writeJsonBody(response);
            return;
        }
    }
    res.statusCode = HTTPStatus.notFound;
    res.headers["OData-Version"] = "4.0";
    res.contentType = "application/json; charset=utf-8";
    res.writeJsonBody(Json.emptyObject);
}
