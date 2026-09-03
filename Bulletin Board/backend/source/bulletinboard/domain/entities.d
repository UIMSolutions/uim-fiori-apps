module bulletinboard.domain.entities;

@safe:

struct Post {
    string postID;
    string title;
    string description;
    string timestamp;
    string category;
    string contact;
    string currency;
    double price;
    bool flagged;
}

struct Category {
    string categoryID;
    string name;
}

struct Comment {
    string commentID;
    string parentID;
    string commentText;
    string author;
    string date;
}

struct PostQuery {
    string titleContains;
    string orderBy;
    bool orderDescending;
    size_t skip;
    size_t top;
    bool hasTop;
}
