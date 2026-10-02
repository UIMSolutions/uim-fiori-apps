module data;

import vibe.data.json;

immutable string[] entitySetNames = ["Products", "Orders"];

Json[] productRows;
Json[] orderRows;

shared static this()
{
	productRows = parseJsonString(`[
	{"ID":1,"Name":"Notebook Basic 15","Category":"Laptops","Price":956.0,"Currency":"EUR","Stock":42,"Rating":4},
	{"ID":2,"Name":"Notebook Pro 17","Category":"Laptops","Price":2299.0,"Currency":"EUR","Stock":8,"Rating":5},
	{"ID":3,"Name":"Flat Screen 24","Category":"Monitors","Price":249.0,"Currency":"EUR","Stock":120,"Rating":4},
	{"ID":4,"Name":"Curved Monitor 34","Category":"Monitors","Price":599.0,"Currency":"EUR","Stock":0,"Rating":5},
	{"ID":5,"Name":"Wireless Keyboard","Category":"Accessories","Price":49.0,"Currency":"EUR","Stock":300,"Rating":3},
	{"ID":6,"Name":"Ergonomic Mouse","Category":"Accessories","Price":39.0,"Currency":"EUR","Stock":15,"Rating":4},
	{"ID":7,"Name":"Docking Station","Category":"Accessories","Price":189.0,"Currency":"EUR","Stock":0,"Rating":3},
	{"ID":8,"Name":"Tablet 10","Category":"Tablets","Price":429.0,"Currency":"EUR","Stock":27,"Rating":4}
	]`).get!(Json[]);
	orderRows = parseJsonString(`[
	{"ID":1001,"Customer":"Very Best Screens","ProductID":3,"Quantity":10,"Total":2490.0,"Currency":"EUR","Status":"Open","OrderDate":"2026-09-28"},
	{"ID":1002,"Customer":"Pear Computing","ProductID":2,"Quantity":2,"Total":4598.0,"Currency":"EUR","Status":"Shipped","OrderDate":"2026-09-29"},
	{"ID":1003,"Customer":"Becker Berlin","ProductID":5,"Quantity":25,"Total":1225.0,"Currency":"EUR","Status":"Shipped","OrderDate":"2026-09-30"},
	{"ID":1004,"Customer":"Pear Computing","ProductID":8,"Quantity":4,"Total":1716.0,"Currency":"EUR","Status":"Open","OrderDate":"2026-10-01"},
	{"ID":1005,"Customer":"Very Best Screens","ProductID":1,"Quantity":3,"Total":2868.0,"Currency":"EUR","Status":"Cancelled","OrderDate":"2026-10-01"}
	]`).get!(Json[]);
}

enum metadataXml = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
  <edmx:DataServices>
    <Schema Namespace="shop" xmlns="http://docs.oasis-open.org/odata/ns/edm">
      <EntityType Name="Product">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.Int32" Nullable="false"/>
        <Property Name="Name" Type="Edm.String"/>
        <Property Name="Category" Type="Edm.String"/>
        <Property Name="Price" Type="Edm.Double"/>
        <Property Name="Currency" Type="Edm.String"/>
        <Property Name="Stock" Type="Edm.Int32"/>
        <Property Name="Rating" Type="Edm.Int32"/>
      </EntityType>
      <EntityType Name="Order">
        <Key><PropertyRef Name="ID"/></Key>
        <Property Name="ID" Type="Edm.Int32" Nullable="false"/>
        <Property Name="Customer" Type="Edm.String"/>
        <Property Name="ProductID" Type="Edm.Int32"/>
        <Property Name="Quantity" Type="Edm.Int32"/>
        <Property Name="Total" Type="Edm.Double"/>
        <Property Name="Currency" Type="Edm.String"/>
        <Property Name="Status" Type="Edm.String"/>
        <Property Name="OrderDate" Type="Edm.Date"/>
      </EntityType>
      <EntityContainer Name="Container">
        <EntitySet Name="Products" EntityType="shop.Product"/>
        <EntitySet Name="Orders" EntityType="shop.Order"/>
      </EntityContainer>
    </Schema>
  </edmx:DataServices>
</edmx:Edmx>`;
