module api.odata_v4;

import vibe.d;

class ODataV4Service
{
    // OData v4 JSON Envelope for EntitySets
    void getProjects(HTTPServerRequest req, HTTPServerResponse res)
    {
        Json response = Json.emptyObject;
        response["@odata.context"] = "$metadata#Projects";
        
        Json[] projects;
        Json p1 = Json.emptyObject;
        p1["ID"] = "PRJ-101";
        p1["Name"] = "S/4HANA Migration 2026";
        p1["Description"] = "Core ERP Modernisierung";
        p1["Status"] = "Active";
        projects ~= p1;

        response["value"] = Json(projects);
        res.writeJsonBody(response);
    }

    void getBusinessRequirements(HTTPServerRequest req, HTTPServerResponse res)
    {
        Json response = Json.emptyObject;
        response["@odata.context"] = "$metadata#BusinessRequirements";
        // $expand support logic for SolutionRequirements
        res.writeJsonBody(response);
    }

    void getSolutionRequirements(HTTPServerRequest req, HTTPServerResponse res)
    {
        Json response = Json.emptyObject;
        response["@odata.context"] = "$metadata#SolutionRequirements";
        res.writeJsonBody(response);
    }

    void getMetadata(HTTPServerRequest req, HTTPServerResponse res)
    {
        res.headers["Content-Type"] = "application/xml";
        res.writeBody(`<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="ReqMgmt" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Project">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="Name" Type="Edm.String"/>
        <NavigationProperty Name="BusinessRequirements" Type="Collection(ReqMgmt.BusinessRequirement)"/>
      </EntityType>
      <EntityType Name="BusinessRequirement">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="ProjectID" Type="Edm.String"/>
        <Property Name="Title" Type="Edm.String"/>
        <NavigationProperty Name="SolutionRequirements" Type="Collection(ReqMgmt.SolutionRequirement)"/>
      </EntityType>
      <EntityType Name="SolutionRequirement">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.String" Nullable="false"/>
        <Property Name="BusinessRequirementID" Type="Edm.String"/>
        <Property Name="Title" Type="Edm.String"/>
      </EntityType>
      <EntityContainer Name="EntityContainer">
        <EntitySet Name="Projects" EntityType="ReqMgmt.Project"/>
        <EntitySet Name="BusinessRequirements" EntityType="ReqMgmt.BusinessRequirement"/>
        <EntitySet Name="SolutionRequirements" EntityType="ReqMgmt.SolutionRequirement"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`);
    }
}