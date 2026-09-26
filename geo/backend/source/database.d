module database;
import vibe.db.postgresql;
import vibe.data.json;
import std.conv : to;

struct LocationQuery {
  string filterColumn;
  string filterValue;
  string orderColumn = "name";
  bool descending = false;
  uint top = 100;
  uint skip = 0;
  bool includeCount = true;
}

struct LocationPage {
  Json[] values;
  ulong totalCount;
  bool hasMore;
}

final class LocationRepository {
  private PostgresClient db;
  this(string connInfo) { db = new PostgresClient(connInfo, 8); }

  void migrate() {
    auto conn = db.lockConnection();
    conn.exec(`CREATE TABLE IF NOT EXISTS locations (
      id varchar(40) PRIMARY KEY,
      name varchar(200) NOT NULL,
      longitude double precision NOT NULL CHECK (longitude BETWEEN -180 AND 180),
      latitude double precision NOT NULL CHECK (latitude BETWEEN -90 AND 90),
      category varchar(60) NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    conn.exec(`INSERT INTO locations(id,name,longitude,latitude,category) VALUES
      ('MUC','München',11.576124,48.137154,'office'),
      ('BER','Berlin',13.404954,52.520008,'office'),
      ('HAM','Hamburg',9.993682,53.551086,'warehouse')
      ON CONFLICT (id) DO NOTHING`);
  }

  LocationPage page(LocationQuery options) {
    LocationPage result;
    auto conn = db.lockConnection();
    string whereClause = options.filterColumn.length ? " WHERE " ~ options.filterColumn ~ " = $1" : "";
    if (options.includeCount) {
      string countSql = "SELECT count(*) AS total FROM locations" ~ whereClause;
      auto countRows = options.filterColumn.length ? ({
        QueryParams params;
        params.sqlCommand = countSql;
        params.argsVariadic(options.filterValue);
        return conn.execParams(params);
      })() : conn.exec(countSql);
      if (countRows.length) result.totalCount = countRows[0]["total"].as!ulong;
    }

    string sql = `SELECT id,name,longitude,latitude,category,created_at FROM locations` ~ whereClause;
    sql ~= " ORDER BY " ~ options.orderColumn ~ (options.descending ? " DESC" : " ASC") ~ ", id ASC";
    QueryParams listParams;
    if (options.filterColumn.length) {
      listParams.sqlCommand = sql ~ " LIMIT $2 OFFSET $3";
      listParams.argsVariadic(options.filterValue, cast(long) options.top + 1, cast(long) options.skip);
    } else {
      listParams.sqlCommand = sql ~ " LIMIT $1 OFFSET $2";
      listParams.argsVariadic(cast(long) options.top + 1, cast(long) options.skip);
    }
    auto rows = conn.execParams(listParams);

    foreach (i; 0 .. rows.length) {
      auto row = rows[i];
      result.values ~= Json([
        "ID": Json(row["id"].as!string),
        "Name": Json(row["name"].as!string),
        "Longitude": Json(row["longitude"].as!double),
        "Latitude": Json(row["latitude"].as!double),
        "Category": Json(row["category"].as!string),
        "CreatedAt": Json(row["created_at"].as!string)
      ]);
    }
    result.hasMore = result.values.length > options.top;
    if (result.hasMore) result.values = result.values[0 .. $ - 1];
    return result;
  }
}