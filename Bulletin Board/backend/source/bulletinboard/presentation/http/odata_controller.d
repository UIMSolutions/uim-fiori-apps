module bulletinboard.presentation.http.odata_controller;

import vibe.d;
import std.conv : to;
import std.string : startsWith, endsWith, split, strip, replace;
import std.algorithm.searching : countUntil;
import bulletinboard.application.usecases.query_service;
import bulletinboard.domain.entities;

@safe:

class ODataV2Controller {
    private BulletinBoardQueryService queryService;
    private immutable string serviceRoot = "/odata/v2/BULLETINBOARD_SRV";

    this(BulletinBoardQueryService queryService) {
        this.queryService = queryService;
    }

    void getHealth(HTTPServerRequest req, HTTPServerResponse res) {
        Json payload = Json.emptyObject;
        payload["status"] = Json("UP");
        payload["service"] = Json("bulletin-board-backend");
        res.writeJsonBody(payload);
    }

    void getServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
        Json posts = Json.emptyObject;
        posts["name"] = Json("Posts");
        posts["kind"] = Json("EntitySet");
        posts["url"] = Json("Posts");

        Json categories = Json.emptyObject;
        categories["name"] = Json("Categories");
        categories["kind"] = Json("EntitySet");
        categories["url"] = Json("Categories");

        Json comments = Json.emptyObject;
        comments["name"] = Json("Comments");
        comments["kind"] = Json("EntitySet");
        comments["url"] = Json("Comments");

        Json entitySets = Json.emptyArray;
        entitySets ~= posts;
        entitySets ~= categories;
        entitySets ~= comments;

        Json workspace = Json.emptyObject;
        workspace["collections"] = entitySets;

        Json payload = Json.emptyObject;
        payload["EntitySets"] = entitySets;
        payload["workspaces"] = Json.emptyArray;
        payload["workspaces"] ~= workspace;

        writeODataV2Object(res, payload);
    }

    void getMetadata(HTTPServerRequest req, HTTPServerResponse res) {
        immutable string xmlMetadata = `<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="1.0" xmlns:sap="http://www.sap.com/Protocols/SAPData" xmlns:edmx="http://schemas.microsoft.com/ado/2007/06/edmx">
    <edmx:DataServices m:DataServiceVersion="2.0" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">
        <Schema Namespace="BULLETINBOARD" xml:lang="en" xmlns="http://schemas.microsoft.com/ado/2008/09/edm">
            <EntityType Name="Post" sap:content-version="1">
                <Key>
                    <PropertyRef Name="PostID"/>
                </Key>
                <Property MaxLength="40" Name="PostID" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Post ID" sap:updatable="false"/>
                <Property MaxLength="255" Name="Title" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Title" sap:updatable="false"/>
                <Property Name="Description" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Description" sap:updatable="false"/>
                <Property Name="Timestamp" Nullable="false" Type="Edm.DateTime" sap:creatable="false" sap:label="Posted On" sap:sortable="true" sap:updatable="false"/>
                <Property MaxLength="60" Name="Category" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Category" sap:sortable="true" sap:updatable="false"/>
                <Property MaxLength="255" Name="Contact" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Contact" sap:sortable="true" sap:updatable="false"/>
                <Property MaxLength="3" Name="Currency" Nullable="false" Type="Edm.String" sap:creatable="false" sap:filterable="false" sap:label="Unit of Measure" sap:sortable="true" sap:updatable="false"/>
                <Property Name="Price" Nullable="false" Precision="23" Scale="4" Type="Edm.Decimal" sap:creatable="false" sap:filterable="false" sap:label="Unit Number" sap:updatable="false"/>
                <Property Name="Flagged" Nullable="false" Type="Edm.Boolean"/>
                <NavigationProperty Name="Comments" ToRole="ToRole_PostToComment" FromRole="FromRole_PostToComment" Relationship="BULLETINBOARD.PostToComment"/>
            </EntityType>

            <EntityType Name="Category" sap:content-version="1">
                <Key>
                    <PropertyRef Name="CategoryID"/>
                </Key>
                <Property MaxLength="60" Name="Name" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Category" sap:sortable="true" sap:updatable="false"/>
            </EntityType>

            <EntityType Name="Comment" sap:content-version="1">
                <Key>
                    <PropertyRef Name="CommentID"/>
                </Key>
                <Property MaxLength="60" Name="CommentID" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="CommentID" sap:sortable="true" sap:updatable="false"/>
                <Property MaxLength="40" Name="ParentID" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="CommentID" sap:sortable="true" sap:updatable="false"/>
                <Property MaxLength="60" Name="CommentText" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Comment" sap:sortable="true" sap:updatable="false"/>
                <Property MaxLength="60" Name="Author" Nullable="false" Type="Edm.String" sap:creatable="false" sap:label="Author" sap:sortable="true" sap:updatable="false"/>
                <Property MaxLength="60" Name="Date" Nullable="false" Type="Edm.DateTime" sap:creatable="false" sap:label="Date" sap:sortable="true" sap:updatable="false"/>
            </EntityType>

            <Association sap:content-version="1" Name="PostToComment">
                <End Type="BULLETINBOARD.Post" Multiplicity="1" Role="FromRole_PostToComment" />
                <End Type="BULLETINBOARD.Comment" Multiplicity="*" Role="ToRole_PostToComment" />
                <ReferentialConstraint>
                    <Principal Role="FromRole_PostToComment">
                        <PropertyRef Name="PostID"/>
                    </Principal>
                    <Dependent Role="ToRole_PostToComment">
                        <PropertyRef Name="ParentID"/>
                    </Dependent>
                </ReferentialConstraint>
            </Association>

            <EntityContainer Name="BULLETINBOARD_ENTITIES" m:IsDefaultEntityContainer="true">
                <EntitySet EntityType="BULLETINBOARD.Post" Name="Posts" sap:content-version="1" sap:creatable="false" sap:deletable="false" sap:pageable="false" sap:updatable="false"/>
                <EntitySet EntityType="BULLETINBOARD.Category" Name="Categories" sap:content-version="1" sap:creatable="false" sap:deletable="false" sap:pageable="false" sap:updatable="false"/>
                <EntitySet EntityType="BULLETINBOARD.Comment" Name="Comments" sap:content-version="1" sap:creatable="true" sap:deletable="false" sap:pageable="false" sap:updatable="false"/>
                <AssociationSet Association="BULLETINBOARD.PostToComment" Name="PostToComentSet" sap:content-version="1" sap:creatable="false" sap:deletable="false" sap:updatable="false">
                    <End EntitySet="Posts" Role="FromRole_PostToComment"/>
                    <End EntitySet="Comments" Role="ToRole_PostToComment"/>
                </AssociationSet>
            </EntityContainer>
        </Schema>
    </edmx:DataServices>
</edmx:Edmx>`;

        res.headers["DataServiceVersion"] = "2.0";
        res.contentType = "application/xml;charset=utf-8";
        res.writeBody(xmlMetadata);
    }

    void getPosts(HTTPServerRequest req, HTTPServerResponse res) {
        PostQuery query = parsePostQuery(req);
        auto total = queryService.countPosts(query);
        auto posts = queryService.listPosts(query);

        Json results = Json.emptyArray;
        foreach (post; posts) {
            results ~= toPostJson(post);
        }

        Json payload = Json.emptyObject;
        payload["results"] = results;
        payload["__count"] = Json(total.to!string);

        writeODataV2Object(res, payload);
    }

    void getPostOrNavigation(HTTPServerRequest req, HTTPServerResponse res) {
        string requestPath = req.requestPath.to!string;
        immutable entityPathPrefix = serviceRoot ~ "/Posts('";

        if (!requestPath.startsWith(entityPathPrefix)) {
            writeNotFound(res, "Unknown posts route");
            return;
        }

        auto suffix = requestPath[entityPathPrefix.length .. $];
        auto keyEnd = countUntil(suffix, "')");
        if (keyEnd < 0) {
            writeBadRequest(res, "Malformed post key in URL");
            return;
        }

        string postID = suffix[0 .. cast(size_t) keyEnd];
        string remainder = suffix[cast(size_t) keyEnd + 2 .. $];

        if (remainder.length == 0 || remainder == "/") {
            auto post = queryService.findPostById(postID);
            if (post is null) {
                writeNotFound(res, "Post not found");
                return;
            }

            writeODataV2Object(res, toPostJson(*post));
            return;
        }

        if (remainder == "/Comments") {
            auto related = queryService.listCommentsByPostId(postID);
            Json items = Json.emptyArray;
            foreach (entry; related) {
                items ~= toCommentJson(entry);
            }

            Json payload = Json.emptyObject;
            payload["results"] = items;
            payload["__count"] = Json(related.length.to!string);
            writeODataV2Object(res, payload);
            return;
        }

        writeNotFound(res, "Unsupported navigation path");
    }

    void getCategories(HTTPServerRequest req, HTTPServerResponse res) {
        auto categories = queryService.listCategories();

        Json items = Json.emptyArray;
        foreach (entry; categories) {
            items ~= toCategoryJson(entry);
        }

        Json payload = Json.emptyObject;
        payload["results"] = items;
        payload["__count"] = Json(categories.length.to!string);
        writeODataV2Object(res, payload);
    }

    void getComments(HTTPServerRequest req, HTTPServerResponse res) {
        auto comments = queryService.listComments();

        Json items = Json.emptyArray;
        foreach (entry; comments) {
            items ~= toCommentJson(entry);
        }

        Json payload = Json.emptyObject;
        payload["results"] = items;
        payload["__count"] = Json(comments.length.to!string);
        writeODataV2Object(res, payload);
    }

    private PostQuery parsePostQuery(HTTPServerRequest req) {
        PostQuery query;
        query.orderBy = "Title";
        query.orderDescending = false;
        query.skip = 0;
        query.top = 0;
        query.hasTop = false;

        foreach (item; req.query.byKeyValue()) {
            auto key = item.key;
            auto value = item.value;

            if (key == "$filter") {
                query.titleContains = parseContainsFilter(value);
            } else if (key == "$orderby") {
                auto orderParts = value.strip.split(" ");
                if (orderParts.length > 0 && orderParts[0].length > 0) {
                    query.orderBy = orderParts[0];
                }
                if (orderParts.length > 1) {
                    query.orderDescending = (orderParts[1].toLower == "desc");
                }
            } else if (key == "$skip") {
                try {
                    query.skip = to!size_t(value);
                } catch (Exception e) {
                }
            } else if (key == "$top") {
                try {
                    query.top = to!size_t(value);
                    query.hasTop = true;
                } catch (Exception e) {
                }
            }
        }

        return query;
    }

    private string parseContainsFilter(string filter) {
        immutable marker = "substringof('";
        auto start = countUntil(filter, marker);
        if (start < 0) {
            return "";
        }

        auto rest = filter[cast(size_t) start + marker.length .. $];
        auto end = countUntil(rest, "',Title)");
        if (end < 0) {
            end = countUntil(rest, "', Title)");
        }

        if (end < 0) {
            return "";
        }

        return rest[0 .. cast(size_t) end].replace("''", "'");
    }

    private Json toPostJson(const ref Post post) {
        Json metadata = Json.emptyObject;
        metadata["uri"] = Json("Posts('" ~ post.postID ~ "')");
        metadata["type"] = Json("BULLETINBOARD.Post");

        Json entity = Json.emptyObject;
        entity["__metadata"] = metadata;
        entity["PostID"] = Json(post.postID);
        entity["Title"] = Json(post.title);
        entity["Description"] = Json(post.description);
        entity["Timestamp"] = Json(post.timestamp);
        entity["Category"] = Json(post.category);
        entity["Contact"] = Json(post.contact);
        entity["Currency"] = Json(post.currency);
        entity["Price"] = Json(post.price);
        entity["Flagged"] = Json(post.flagged);
        return entity;
    }

    private Json toCategoryJson(const ref Category category) {
        Json metadata = Json.emptyObject;
        metadata["uri"] = Json("Categories('" ~ category.categoryID ~ "')");
        metadata["type"] = Json("BULLETINBOARD.Category");

        Json entity = Json.emptyObject;
        entity["__metadata"] = metadata;
        entity["CategoryID"] = Json(category.categoryID);
        entity["Name"] = Json(category.name);
        return entity;
    }

    private Json toCommentJson(const ref Comment comment) {
        Json metadata = Json.emptyObject;
        metadata["uri"] = Json("Comments('" ~ comment.commentID ~ "')");
        metadata["type"] = Json("BULLETINBOARD.Comment");

        Json entity = Json.emptyObject;
        entity["__metadata"] = metadata;
        entity["CommentID"] = Json(comment.commentID);
        entity["ParentID"] = Json(comment.parentID);
        entity["CommentText"] = Json(comment.commentText);
        entity["Author"] = Json(comment.author);
        entity["Date"] = Json(comment.date);
        return entity;
    }

    private void writeODataV2Object(HTTPServerResponse res, Json payload) {
        Json root = Json.emptyObject;
        root["d"] = payload;
        res.headers["DataServiceVersion"] = "2.0";
        res.writeJsonBody(root);
    }

    private void writeBadRequest(HTTPServerResponse res, string message) {
        res.statusCode = cast(int) HTTPStatus.badRequest;

        Json error = Json.emptyObject;
        error["code"] = Json("400");
        error["message"] = Json(message);

        Json payload = Json.emptyObject;
        payload["error"] = error;
        res.writeJsonBody(payload);
    }

    private void writeNotFound(HTTPServerResponse res, string message) {
        res.statusCode = cast(int) HTTPStatus.notFound;

        Json error = Json.emptyObject;
        error["code"] = Json("404");
        error["message"] = Json(message);

        Json payload = Json.emptyObject;
        payload["error"] = error;
        res.writeJsonBody(payload);
    }
}
