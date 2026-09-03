module bulletinboard.application.ports.repository;

import bulletinboard.domain.entities;

@safe:

interface BulletinBoardRepository {
    Post[] listPosts(PostQuery query);
    size_t countPosts(PostQuery query);
    Post* findPostById(string postID);
    Category[] listCategories();
    Comment[] listComments();
    Comment[] listCommentsByPostId(string postID);
}
