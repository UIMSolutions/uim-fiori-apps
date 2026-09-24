module uim.fiori_blocks.infrastructure.repositories.repository;

import uim.fiori_blocks;

@safe:

class BlockRepository(T) {
    T[string] _blocks;

    this() {
    }
    
    bool existsById(string id) {
        return id in _blocks ? true : false;
    }

    bool existsAll(T[] blocks) {
        return blocks.all!(block => existsById(block.ID));
    }

    bool existsAny(T[] blocks) {
        return blocks.any!(block => existsById(block.ID));
    }

    bool exists(T block) {
        return existsById(block.ID);
    }

    T[] findAll() {
        return _blocks.values();
    }

    T findById(string id) {
        return existsById(id) ? _blocks[id] : T.init;
    }

    void update(T block) {
        if (existsById(block.ID)) {
            _blocks[block.ID] = block;
        }
    }

    void update(T[] blocks) {
        blocks.each!(block => update(block));
    }

    void save(T[] blocks) {
        blocks.each!(block => save(block));
    }

    void save(T block) {
        _blocks[block.ID] = block;
    }

    void removeById(string[] ids) {
        ids.each!(id => removeById(id));
    }

    void removeById(string id) {
        _blocks.remove(id);
    }

    void remove(T[] blocks) {
        blocks.each!(block => remove(block));
    }

    void remove(T block) {
        _blocks.remove(block.ID);
    }
}