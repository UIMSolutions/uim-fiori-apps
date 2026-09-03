module uim.fiori.odata.metadata;

import uim.fiori;

@safe:

class ODataMetadataGenerator {

    /// Generiert das EDMX-XML für eine Liste von registrierten D-Strukturen
    static string generateEdmx(string namespaceName, T...)() {
        auto app = appender!string();

        app.put(`<?xml version="1.0" encoding="utf-8"?>`);
        app.put(`<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">`);
        app.put(`  <edmx:DataServices>`);
        app.put(format(`    <Schema Namespace="%s" xmlns="http://docs.oasis-open.org/odata/ns/edm">`, namespaceName));

        // EntityTypes generieren
        // static foreach (Type; T) {
        //     {
        //         app.put(format(`      <EntityType Name="%s">`, Type.stringof));

        //         static foreach (mem; FieldNameTuple!Type) {
        //             {zapp
        //                 // Direktes Pruefen der UDAs auf dem Symbol
        //                 enum isIgnored = hasUDA!(__traits(getMember, Type, mem), ODataIgnore);

        //                 static if (!isIgnored) {
        //                     alias FieldType = typeof(__traits(getMember, Type, mem));
        //                     enum isKey = hasUDA!(__traits(getMember, Type, mem), ODataKey);

        //                     app.put(format(`        <Property Name="%s" Type="%s" Nullable="false"/>`,
        //                             mem, mapToEdmType!FieldType()));

        //                     static if (isKey) {
        //                         app.put(format(`        <Key><PropertyRef Name="%s"/></Key>`, mem));
        //                     }
        //                 }
        //             }
        //         }
        //         app.put(`      </EntityType>`);
        //     }
        // }
        // 1. EntityTypes
        static foreach (Type; T) {
            {
                app.put(ODataMetadataGenerator.generateEntityType!Type(namespaceName));
            }
        }

        // EntityContainer generieren
        app.put(`      <EntityContainer Name="EntityContainer">`);
        // static foreach (Type; T) {
        //     {
        //         enum setName = ODataMetadataGenerator.getEntitySetName!Type();
        //         app.put(format(`        <EntitySet Name="%s" EntityType="%s.%s"/>`,
        //                 setName, namespaceName, Type.stringof));
        //     }
        // }
        static foreach (Type; T) {
            {
                app.put(ODataMetadataGenerator.generateEntitySet!Type(namespaceName));
            }
        }
        app.put(`      </EntityContainer>`);

        app.put(`    </Schema>`);
        app.put(`  </edmx:DataServices>`);
        app.put(`</edmx:Edmx>`);

        return app.data;
    }

    unittest {
        writeln("Testing generateEdmx...");

        struct Product {
            @ODataKey
            string Id;
            string Name;
            double Price;
        }

        struct Customer {
            @ODataKey
            string Id;
            string FirstName;
            string LastName;
        }

        void test() {
            string edmx = ODataMetadataGenerator.generateEdmx!("MyNamespace", Product, Customer)();
            assert(edmx.length > 0);
        }

        test();
    }

    protected static string getEntitySetName(T)() {
        static if (hasUDA!(T, ODataEntitySet)) {
            return getUDAs!(T, ODataEntitySet)[0].name;
        } else {
            string name = T.stringof;
            // Endet der Name auf s, x, z, ch oder sh -> "es" anhängen (z.B. Address -> Addresses)
            if (name.endsWith("s") || name.endsWith("x") || name.endsWith("z") ||
                name.endsWith("ch") || name.endsWith("sh")) {
                return name ~ "es";
            }
            return name ~ "s";
        }
    }

    unittest {
        writeln("Testing getEntitySetName...");

        struct Product {
            @ODataKey
            string Id;
            string Name;
        }

        struct Address {
            @ODataKey
            string Id;
            string Street;
        }

        void test() {
            assert(ODataMetadataGenerator.getEntitySetName!Product() == "Products");
            assert(ODataMetadataGenerator.getEntitySetName!Address() == "Addresses");
        }

        test();
    }

    protected static string mapToEdmType(T)() {
        static if (is(T == string))
            return "Edm.String";
        else static if (is(T == int) || is(T == uint))
            return "Edm.Int32";
        else static if (is(T == long) || is(T == ulong))
            return "Edm.Int64";
        else static if (is(T == double) || is(T == float))
            return "Edm.Double";
        else static if (is(T == bool))
            return "Edm.Boolean";
        else
            return "Edm.String";
    }
    /// 
    unittest {
        writeln("Testing generateEdmx...");

        import std.stdio;
        import std.conv;

        struct Address {
            @ODataKey
            string Id;

            string FirstName;
            string LastName;
            string Street;
            string City;
            string PostalCode;
            string Country;
        }

        void test() {
            string edmx = ODataMetadataGenerator.generateEdmx!("AddressService", Address)();
            writeln(edmx);
        }

        test();
    }

    protected static template isField(T, string memberName) {
        enum isField = __traits(compiles, {
                alias m = __traits(getMember, T, memberName);
                static if (!isCallable!m && !isType!m) {
                }
            });
    }

    unittest {
        writeln("Testing isField...");

        struct TestStruct {
            int a;
            string b;
            void method() {
            }
        }

        void test() {
            assert(isField!(TestStruct, "a"));
            assert(isField!(TestStruct, "b"));
            // assert(!isField!(TestStruct, "method"));
        }

        test();
    }

    protected static string findReferencedKeyProperty(TargetEntity)() {
        writeln("\nSearching for referenced key property in ", TargetEntity.stringof);

        static foreach (memberName; __traits(allMembers, TargetEntity)) {
            {
                writeln("Checking member: ", memberName);

                static if (isField!(TargetEntity, memberName)) {
                    writeln("Member is a field: ", memberName);

                    alias member = __traits(getMember, TargetEntity, memberName);
                    static if (hasUDA!(member, ODataKey)) {
                        writeln("Member has ODataKey UDA: ", memberName);

                        return memberName.toODataPascalCase();
                    }
                }
            }
        }
        return "";
    }

    protected static string findForeignKeyProperty(T, TargetEntity)() {
        writeln("\nSearching for foreign key property in ", T.stringof, " referencing ", TargetEntity
                .stringof);

        static foreach (memberName; __traits(allMembers, T)) {
            { // For each member of T
                writeln("Checking member: ", memberName);

                static if (isField!(T, memberName)) { // Check if it's a field
                    writeln("Member is a field: ", memberName);

                    alias member = __traits(getMember, T, memberName); // Get the member symbol
                    static if (hasUDA!(member, ODataForeignKey)) { // Check if it has the ODataForeignKey UDA
                        writeln("Member has ODataForeignKey UDA: ", memberName);

                        // Get the type of the member
                        alias MemberType = typeof(member);
                        // Check if the type of the member is the same as TargetEntity
                        static if (is(MemberType == TargetEntity)) { // Check if the type matches Target
                            writeln("Member type matches TargetEntity: ", memberName);

                            return memberName.toODataPascalCase();
                        }
                    }
                }
            }
        }
        return "";
    }

    unittest {
        writeln("Testing findForeignKeyProperty and findReferencedKeyProperty...");

        struct Customer {
            @ODataKey
            string Id;
            string Name;
        }

        struct Order {
            @ODataKey
            string Id;

            @ODataForeignKey
            Customer customer; // Foreign key to Customer
        }

        void test() {
            string fkProp = ODataMetadataGenerator.findForeignKeyProperty!(Order, Customer)();
            string refProp = ODataMetadataGenerator.findReferencedKeyProperty!Customer();

            writeln("Foreign key property in Order: ", fkProp);
            writeln("Referenced key property in Customer: ", refProp);
            assert(fkProp == "Customer");
            assert(refProp == "Id");

        }

        test();
    }

    protected static string generateEntityType(T)(string namespaceName = "ODataService") {
        string entityTypeName = T.stringof;
        string xml = "      <EntityType Name=\"" ~ entityTypeName ~ "\">\n";

        // A) Key-Definition
        string keyName = "";
        static foreach (memberName; __traits(allMembers, T)) {
            {
                static if (__traits(compiles, __traits(getMember, T, memberName))) {
                    alias member = __traits(getMember, T, memberName);
                    static if (hasUDA!(member, ODataKey)) {
                        keyName = memberName.toODataPascalCase();
                    }
                }
            }
        }
        if (keyName.length > 0) {
            xml ~= "        <Key>\n";
            xml ~= "          <PropertyRef Name=\"" ~ keyName ~ "\" />\n";
            xml ~= "        </Key>\n";
        }

        // B) Standard Properties (Primitive Typen)
        xml ~= ODataMetadataGenerator.standardProperties!T();

        // C) Navigation Properties (1:1 und 1:N)
        xml ~= ODataMetadataGenerator.navigationProperties!T(namespaceName);

        xml ~= "      </EntityType>\n";
        return xml;
    }

    protected static string generateEntitySet(T)(string namespaceName = "ODataService") {
        string entitySetName = getEntitySetName!T();
        string xml = "        <EntitySet Name=\"" ~ entitySetName ~ "\" EntityType=\"" ~ namespaceName ~ "." ~ T
            .stringof ~ "\">\n";

        // NavigationPropertyBindings für den EntityContainer generieren
        static foreach (memberName; __traits(allMembers, T)) {
            static if (isField!(T, memberName)) {
                {
                    alias member = __traits(getMember, T, memberName);
                    alias MemberType = typeof(member);

                    static if (hasUDA!(member, ODataNavigationProperty)) {
                        string navName = memberName.capitalize();

                        static if (isArray!MemberType) {
                            alias TargetEntity = ElementType!MemberType;
                            xml ~= navigationPropertyBindingArray!TargetEntity(navName);
                        } else static if (is(MemberType == struct)) {
                            alias TargetEntity = MemberType;
                            xml ~= "          <NavigationPropertyBinding Path=\"" ~ navName ~ "\" Target=\"" ~ getEntitySetName!TargetEntity() ~ "\" />\n";
                        }
                    }
                }
            }
        }

        xml ~= "        </EntitySet>\n";
        return xml;
    }

    unittest {
        writeln("Testing generateEntityType and generateEntitySet...");

        struct Customer {
            @ODataKey
            string Id;
            string Name;
        }

        struct Order {
            @ODataKey
            string Id;

            @ODataForeignKey
            Customer customer; // Foreign key to Customer

            @ODataNavigationProperty
            Customer customerNav; // Navigation property to Customer
        }

        void test() {
            string entityTypeXml = ODataMetadataGenerator.generateEntityType!Order();
            string entitySetXml = ODataMetadataGenerator.generateEntitySet!Order();

            writeln("Generated EntityType XML:\n", entityTypeXml);
            writeln("Generated EntitySet XML:\n", entitySetXml);
        }

        test();
    }

    static string standardProperty(string propertyName, string edmType) {
        return format(`        <Property Name="%s" Type="%s" />`, propertyName, edmType);
    }

    unittest {
        writeln("Testing standardProperty...");

        void test() {
            string propXml = standardProperty("Name", "Edm.String");
            writeln("Generated Property XML:\n", propXml);
            assert(propXml == `        <Property Name="Name" Type="Edm.String" />`);
        }

        test();
    }

    static string navigationProperty1_N(string propertyName, string targetEntity) {
        return format(`        <NavigationProperty Name="%s" Type="Collection(%s)" />`, propertyName, targetEntity);
    }

    unittest {
        writeln("Testing navigationProperty1_N...");

        void test() {
            string navPropXml = navigationProperty1_N("Orders", "MyNamespace.Order");
            writeln("Generated NavigationProperty XML:\n", navPropXml);
            assert(
                navPropXml == `        <NavigationProperty Name="Orders" Type="Collection(MyNamespace.Order)" />`);
        }

        test();
    }

    static string navigationProperty1_1(string propertyName, string targetEntity, string fkProperty, string refProperty) {
        auto xml = "        <NavigationProperty Name=\"" ~ propertyName ~ "\" Type=\"" ~ targetEntity ~ "\"";

        if (fkProperty.length > 0 && refProperty.length > 0) {
            xml ~= ">\n";
            xml ~= "          <ReferentialConstraint Property=\"" ~ fkProperty ~ "\" ReferencedProperty=\"" ~ refProperty ~ "\" />\n";
            xml ~= "        </NavigationProperty>\n";
        } else {
            xml ~= " />\n";
        }

        return xml;
    }

    unittest {
        writeln("Testing navigationProperty1_1...");

        void test() {
            string navPropXml = navigationProperty1_1("Customer", "MyNamespace.Customer", "CustomerId", "Id");
            writeln("Generated NavigationProperty XML:\n", navPropXml);
            assert(
                navPropXml == `        <NavigationProperty Name="Customer" Type="MyNamespace.Customer">
          <ReferentialConstraint Property="CustomerId" ReferencedProperty="Id" />
        </NavigationProperty>
`);
        }

        test();
    }

    static string navigationPropertyBindingArray(TargetEntity)(string navName) {
        alias TargetEntity = ElementType!MemberType;
        return "          <NavigationPropertyBinding Path=\"" ~ navName ~ "\" Target=\"" ~ getEntitySetName!TargetEntity() ~ "\" />\n";
    }

    static string standardProperties(T)() {
        string xml;
        // B) Standard Properties (Primitive Typen)
        static foreach (memberName; __traits(allMembers, T)) {
            {
                static if (isField!(T, memberName)) {
                    alias member = __traits(getMember, T, memberName);
                    alias MemberType = typeof(member);

                    static if (!hasUDA!(member, ODataNavigationProperty)) {
                        string propName = memberName.toODataPascalCase();
                        string edmType = mapToEdmType!MemberType();
                        xml ~= standardProperty(propName, edmType);
                    }
                }
            }
        }
        return xml;
    }

    static string navigationProperties(T)(string namespaceName = "ODataService") {
        string xml;
        // C) Navigation Properties (1:1 und 1:N)
        static foreach (memberName; __traits(allMembers, T)) {
            {
                static if (isField!(T, memberName)) {
                    alias member = __traits(getMember, T, memberName);
                    alias MemberType = typeof(member);

                    static if (hasUDA!(member, ODataNavigationProperty)) {
                        string navName = memberName.capitalize();

                        static if (isArray!MemberType) {
                            alias TargetEntity = ElementType!MemberType;
                            xml ~= navigationProperty1_N(navName, namespaceName ~ "." ~ TargetEntity.stringof);
                        } else static if (is(MemberType == struct)) {
                            alias TargetEntity = MemberType;
                            string fkProperty = findForeignKeyProperty!(T, TargetEntity)();
                            string refProperty = findReferencedKeyProperty!TargetEntity();
                            xml ~= navigationProperty1_1(navName, namespaceName ~ "." ~ TargetEntity.stringof, fkProperty,
                                refProperty);
                        }
                    }
                }
            }
        }
        return xml;
    }
}
