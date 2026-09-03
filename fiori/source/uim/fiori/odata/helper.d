module uim.fiori.odata.helper;

import uim.fiori;

@safe:

string toODataPascalCase(string name) {
    if (name.length == 0) return name;
    import std.uni : toUpper, toLower;
    import std.conv : to;
    // Wenn das Feld "id" heißt, explizit zu "Id" formatieren
    if (name == "id" || name == "ID") return "Id";
    
    // Standard PascalCase: erster Buchstabe groß, Rest unverändert
    return name[0..1].toUpper.to!string ~ name[1..$];
}