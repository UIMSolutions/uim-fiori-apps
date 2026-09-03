module bulletinboard.infrastructure.repositories.in_memory_repository;

import bulletinboard.application.ports.repository;
import bulletinboard.domain.entities;
import std.algorithm.searching : countUntil;
import std.array : array;
import std.range : iota;
import std.string : toLower;

@safe:

class InMemoryBulletinBoardRepository : BulletinBoardRepository {
    private Post[] posts;
    private Category[] categories;
    private Comment[] comments;

    this() {
        categories = [
            Category("1", "Bicycles"),
            Category("2", "Car Parts"),
            Category("3", "Toys"),
            Category("4", "Sports"),
            Category("5", "Multimedia"),
            Category("6", "Miscellaneous"),
            Category("7", "Furniture"),
            Category("8", "Clothing")
        ];

        posts = [
            Post("PostID_1", "29'er Mountain Bike (red)", "A great mountainbike, barely used and good as new. Pedals and saddle included", "/Date(1428223780000)/", "Bicycles", "contact.me07@gmail.com", "USD", 81, false),
            Post("PostID_2", "Football (rare with signatures)", "A trophy for collectors, 2014 football with original signatures from the german national soccer team and the spirit of the world cup.", "/Date(1428504382000)/", "Sports", "soccernerd@hotmail.de", "EUR", 420, false),
            Post("PostID_3", "Video Games", "A collection of 22 classic video games from 1986 to 1992, old but still a lot of fun", "/Date(1433357393000)/", "Multimedia", "RogerRoger@gmail.com", "USD", 27, false),
            Post("PostID_4", "Fluffy Teddy Bear", "This little companion is looking for a new friend, it is brown and has black eyes. One ear is missing.", "/Date(1429892877000)/", "Toys", "rainbow.glitter03@gmail.com", "USD", 13, true),
            Post("PostID_5", "Car Tires, 22 Inch", "Spare winter tires for a compact-size car, 4 tires with good profile.", "/Date(1423579562000)/", "Car parts", "superpacer@gmail.com", "USD", 121, false),
            Post("PostID_6", "Garage Door with Blue Stripes, 4m x 2,2m", "Good as new, a garage door for a standard double garage, keeps cars dry and carjackers away.", "/Date(1431603971000)/", "Car parts", "john.doe@gmail.com", "USD", 481, true),
            Post("PostID_7", "Kids Toys, a Whole Box of Stuff", "Best suited for kids aged from 4-10, a whole box of toys including model cars, marble balls, toy figures, and much more.", "/Date(1435603415000)/", "Toys", "AGreatDeal@gmail.com", "USD", 63, false),
            Post("PostID_8", "Screwdrivers", "20-Piece Multibit Ratcheting Screwdriver Set", "/Date(1439273334000)/", "Miscellaneous", "houseofparts@gmail.com", "USD", 28, false),
            Post("PostID_9", "Comfortable Bike Saddle", "A brand-new, unused bike saddle with black covering", "/Date(1426606523000)/", "Bicycles", "gotIt@gmail.com", "USD", 25, false),
            Post("PostID_10", "Bike Rack", "Suitable for camper or RV, used", "/Date(1429871021000)/", "Bicycles", "MajorRefactoring@gmail.com", "USD", 106, true),
            Post("PostID_11", "DVD: Trains of Europe", "An amazing collection of train models all around Europe, total runtime 412 minutes.", "/Date(1425446058000)/", "Multimedia", "hopOnTheTrain@gmail.com", "USD", 61, false),
            Post("PostID_12", "Matress", "Bed Mattress 30 x 70 inch, filled with natural fibers, barely used", "/Date(1435612710000)/", "Miscellaneous", "abc@gmail.com", "USD", 306, false),
            Post("PostID_13", "High-End Gamer PC", "3Ghz dual core, 16gb RAM, high tower. Great for playing the latest games.", "/Date(1436435262000)/", "Furniture", "player.mike@gmail.com", "USD", 256, false),
            Post("PostID_14", "Cooking Pot Set", "Stainless steel cooking pots (10 pcs) with a matching lid each.", "/Date(1427938348000)/", "Miscellaneous", "abc@gmail.com", "USD", 234, false),
            Post("PostID_15", "Jeans", "Used-look Jeans european size 32x34, only worn once.", "/Date(1437280068000)/", "Clothing", "sellTwoPairs@gmail.com", "EUR", 34, false),
            Post("PostID_16", "Moving Boxes", "100 Cardboard boxes perfect for relocating, only used once and in a pretty good shape.", "/Date(1424653593000)/", "Miscellaneous", "overhaul08@gmail.com", "USD", 60, false),
            Post("PostID_17", "Car VW Golf (white)", "Only 160.000 km and in really good shape, grip shift, contact me for appointment and more details.", "/Date(1436927019000)/", "Car Parts", "james.McGillan@gmail.com", "USD", 3006, false),
            Post("PostID_18", "Swimming Pool", "Perfect for your very own pool parties in the garden, measures: 5x10m, fill with ~500.000l water and enjoy.", "/Date(1436402641000)/", "Miscellaneous", "poollov3r@gmail.com", "USD", 4587, false),
            Post("PostID_19", "Travel Suitcases", "New and in original packaging, a set of 5 high-quality suitcases from small to large sizes.", "/Date(1426837938000)/", "Miscellaneous", "aroundtheworld@hotmail.com", "USD", 560, false),
            Post("PostID_20", "Rainbow Stickers", "A vast collection of rainbow stickers for collectors, about 2.000 individual pieces in all shapes and sizes", "/Date(1430961733000)/", "Miscellaneous", "james.holden@gmail.com", "USD", 45, true),
            Post("PostID_21", "Notebook", "Used notebook with broken display, needs repair. A bargain for the DIY tech guy.", "/Date(1438286726000)/", "Multimedia", "to.felldown@gmail.com", "USD", 23, false),
            Post("PostID_22", "Plasma TV 60\"!", "I got a larger one, so selling this one cheap for all the movie lovers out there", "/Date(1425501468000)/", "Multimedia", "large.one@gmail.com", "USD", 360, false),
            Post("PostID_23", "Cheap Boat", "Living close to a lake or the ocean? This dream of a yacht (30ft long!) comes with lots of extras. Get it and fulfill yourself a dream.", "/Date(1439561313000)/", "Miscellaneous", "gotboats@gmail.com", "USD", 26263, false)
        ];

        comments = [
            Comment("CommentID 1", "PostID_1", "Nice bike, I will definitely consider buying", "John", "/Date(1271774249000)/"),
            Comment("CommentID 2", "PostID_1", "Is it also suitable for girls?", "Lisa", "/Date(1179931049000)/"),
            Comment("CommentID 3", "PostID_1", "Depends on your size I guess", "Michael", "/Date(1423579562000)/"),
            Comment("CommentID 4", "PostID_2", "OMG I need this, I was actually at this game", "Jens", "/Date(1086964649000)/"),
            Comment("CommentID 5", "PostID_2", "Really? It must be a fake for this price", "Raynor", "/Date(1423579562000)/"),
            Comment("CommentID 6", "PostID_2", "Can you post a picture please so that we can have proof?", "Klaus", "/Date(1431603971000)/"),
            Comment("CommentID 7", "PostID_2", "Unfortunately, my camera is broken right now, will post something later", "John", "/Date(1217083049000)/"),
            Comment("CommentID 8", "PostID_2", "Oh really?!", "Raynor", "/Date(1217083068000)/"),
            Comment("CommentID 9", "PostID_15", "What color are they? blue?", "Andy", "/Date(1280155049000)/"),
            Comment("CommentID 10", "PostID_15", "I am interested in the color as well", "Amy", "/Date(1335364649000)/")
        ];
    }

    override Post[] listPosts(PostQuery query) {
        auto filtered = filterPosts(query);

        if (!query.hasTop && query.skip == 0) {
            return filtered;
        }

        size_t start = query.skip;
        if (start > filtered.length) {
            start = filtered.length;
        }

        size_t end = filtered.length;
        if (query.hasTop) {
            end = start + query.top;
            if (end > filtered.length) {
                end = filtered.length;
            }
        }

        return filtered[start .. end].dup;
    }

    override size_t countPosts(PostQuery query) {
        return filterPosts(query).length;
    }

    override Post* findPostById(string postID) {
        foreach (idx; 0 .. posts.length) {
            if (posts[idx].postID == postID) {
                return &posts[idx];
            }
        }
        return null;
    }

    override Category[] listCategories() {
        return categories.dup;
    }

    override Comment[] listComments() {
        return comments.dup;
    }

    override Comment[] listCommentsByPostId(string postID) {
        Comment[] matches;
        foreach (entry; comments) {
            if (entry.parentID == postID) {
                matches ~= entry;
            }
        }
        return matches;
    }

    private Post[] filterPosts(PostQuery query) {
        Post[] result = posts.dup;

        if (query.titleContains.length > 0) {
            Post[] titleFiltered;
            auto needle = query.titleContains.toLower;
            foreach (entry; result) {
                if (countUntil(entry.title.toLower, needle) >= 0) {
                    titleFiltered ~= entry;
                }
            }
            result = titleFiltered;
        }

        sortPosts(result, query.orderBy, query.orderDescending);
        return result;
    }

    private void sortPosts(ref Post[] values, string orderBy, bool descending) {
        if (values.length < 2) {
            return;
        }

        foreach (i; iota(values.length)) {
            foreach (j; i + 1 .. values.length) {
                if (mustSwap(values[i], values[j], orderBy, descending)) {
                    auto tmp = values[i];
                    values[i] = values[j];
                    values[j] = tmp;
                }
            }
        }
    }

    private bool mustSwap(const ref Post left, const ref Post right, string orderBy, bool descending) {
        int cmp;
        switch (orderBy) {
            case "Price":
                if (left.price < right.price) {
                    cmp = -1;
                } else if (left.price > right.price) {
                    cmp = 1;
                }
                break;
            case "Timestamp":
                cmp = compareString(left.timestamp, right.timestamp);
                break;
            case "Category":
                cmp = compareString(left.category, right.category);
                break;
            case "Title":
            default:
                cmp = compareString(left.title, right.title);
                break;
        }

        return descending ? (cmp < 0) : (cmp > 0);
    }

    private int compareString(string a, string b) {
        if (a < b) {
            return -1;
        }
        if (a > b) {
            return 1;
        }
        return 0;
    }
}
