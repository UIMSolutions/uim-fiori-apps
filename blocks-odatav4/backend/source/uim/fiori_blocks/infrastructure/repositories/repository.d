/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.infrastructure.repositories.repository;

import uim.fiori_blocks;

@safe:

class BlockRepository(T) {
    T[string] _blocks;

    this() {
    }
    
    bool exists(string id) {
        return id in _blocks ? true : false;
    }

    bool existsAll(string[] ids) {
        return ids.all!(id => exists(id));
    }

    bool existsAny(string[] ids) {
        return ids.any!(id => exists(id));
    }

    bool existsAll(T[] blocks) {
        return blocks.all!(block => exists(block.ID));
    }

    bool existsAny(T[] blocks) {
        return blocks.any!(block => exists(block.ID));
    }

    bool exists(T block) {
        return exists(block.ID);
    }

    T[] findAll() {
        return _blocks.values();
    }

    T find(string id) {
        return exists(id) ? _blocks[id] : T.init;
    }

    void update(T block) {
        if (exists(block.ID)) {
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

    void remove(string[] ids) {
        ids.each!(id => remove(id));
    }

    void remove(string id) {
        _blocks.remove(id);
    }

    void remove(T[] blocks) {
        blocks.each!(block => remove(block));
    }

    void remove(T block) {
        _blocks.remove(block.ID);
    }
}