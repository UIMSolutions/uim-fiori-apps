module bulletinboard.application.usecases.query_service;

import bulletinboard.application.ports.repository;
import bulletinboard.domain.entities;

@safe:

class BulletinBoardQueryService {
    private BulletinBoardRepository repository;

    this(BulletinBoardRepository repository) {
        this.repository = repository;
    }

    Post[] listPosts(PostQuery query) {
        return repository.listPosts(query);
    }

    size_t countPosts(PostQuery query) {
        return repository.countPosts(query);
    }

    Post* findPostById(string postID) {
        return repository.findPostById(postID);
    }

    Category[] listCategories() {
        return repository.listCategories();
    }

    Comment[] listComments() {
        return repository.listComments();
    }

    Comment[] listCommentsByPostId(string postID) {
        return repository.listCommentsByPostId(postID);
    }
}
