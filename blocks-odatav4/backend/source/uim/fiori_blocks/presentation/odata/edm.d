/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.presentation.odata.edm;

/// Generates the OData v4 CSDL ($metadata) and the service document from the catalog.
/// The metadata is derived from the domain structs, so it can never drift from the data again
/// (the former hand-written XML declared `SolutionBlock` twice and `DependsOn` as navigation).
import std.array : appender;
import std.format : formattedWrite;

import vibe.data.json : Json;

import uim.fiori_blocks.application.dtos.metadata;
import uim.fiori_blocks.application.services.catalog;

@safe:

string edmType(const ref PropertyInfo property, string namespace) pure {
  string base;
  final switch (property.kind) {
  case PrimitiveKind.string_:
    base = "Edm.String";
    break;
  case PrimitiveKind.boolean:
    base = "Edm.Boolean";
    break;
  case PrimitiveKind.int32:
    base = "Edm.Int32";
    break;
  case PrimitiveKind.int64:
    base = "Edm.Int64";
    break;
  case PrimitiveKind.double_:
    base = "Edm.Double";
    break;
  case PrimitiveKind.complex:
    base = namespace ~ "." ~ property.complexType;
    break;
  }
  return property.collection ? "Collection(" ~ base ~ ")" : base;
}

string generateMetadata(ServiceCatalog catalog, string namespace, string container) {
  auto xml = appender!string;
  xml ~= `<?xml version="1.0" encoding="utf-8"?>` ~ "\n";
  xml ~= `<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">` ~ "\n";
  xml ~= `  <edmx:DataServices>` ~ "\n";
  xml.formattedWrite!`    <Schema Namespace="%s" xmlns="http://docs.oasis-open.org/odata/ns/edm">%s`(namespace, "\n");

  bool[string] writtenComplex;
  foreach (service; catalog.all) {
    foreach (complex; service.complexTypes) {
      if (complex.name in writtenComplex)
        continue;
      writtenComplex[complex.name] = true;
      xml.formattedWrite!`      <ComplexType Name="%s">%s`(complex.name, "\n");
      foreach (property; complex.properties)
        writeProperty(xml, property, namespace);
      xml ~= "      </ComplexType>\n";
    }
  }

  foreach (service; catalog.all) {
    xml.formattedWrite!`      <EntityType Name="%s">%s`(service.typeName, "\n");
    xml.formattedWrite!`        <Key><PropertyRef Name="%s"/></Key>%s`(service.keyProperty, "\n");
    foreach (property; service.properties)
      writeProperty(xml, property, namespace);
    xml ~= "      </EntityType>\n";
  }

  xml.formattedWrite!`      <EntityContainer Name="%s">%s`(container, "\n");
  foreach (service; catalog.all)
    xml.formattedWrite!`        <EntitySet Name="%s" EntityType="%s.%s"/>%s`(service.name, namespace, service.typeName, "\n");
  xml ~= "      </EntityContainer>\n";
  xml ~= "    </Schema>\n  </edmx:DataServices>\n</edmx:Edmx>\n";
  return xml.data;
}

private void writeProperty(W)(ref W xml, const ref PropertyInfo property, string namespace) {
  xml.formattedWrite!`        <Property Name="%s" Type="%s"%s/>%s`(property.name, edmType(property, namespace),
    property.key || property.collection ? ` Nullable="false"` : "", "\n");
}

/// Service document (GET on the service root).
Json serviceDocument(ServiceCatalog catalog, string serviceRoot) {
  Json[] sets;
  foreach (service; catalog.all)
    sets ~= Json(["name": Json(service.name), "kind": Json("EntitySet"), "url": Json(service.name)]);
  return Json(["@odata.context": Json(serviceRoot ~ "$metadata"), "value": Json(sets)]);
}
