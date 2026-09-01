module uim.fiori.admin.models;

import std.datetime : Clock;
import std.conv : to;

@safe:

struct AdminUser {
    string id;
    string username;
    string email;
    string role;
    bool active;
    string createdAt;
}

class UserRepository {
private:
    AdminUser[] m_users;
    size_t m_nextId = 1000;

public:
    this() {
        seed();
    }

    AdminUser[] list() const {
        return m_users.dup;
    }

    AdminUser getById(string id) const {
        foreach (u; m_users) {
            if (u.id == id) {
                return u;
            }
        }
        return AdminUser.init;
    }

    AdminUser create(AdminUser user) {
        user.id = to!string(m_nextId++);
        user.createdAt = Clock.currTime().toISOString();
        m_users ~= user;
        return user;
    }

    AdminUser update(string id, AdminUser user) {
        foreach (i, existing; m_users) {
            if (existing.id == id) {
                user.id = id;
                if (user.createdAt.length == 0) {
                    user.createdAt = existing.createdAt;
                }
                m_users[i] = user;
                return m_users[i];
            }
        }
        return AdminUser.init;
    }

    bool remove(string id) {
        foreach (i, u; m_users) {
            if (u.id == id) {
                m_users = m_users[0 .. i] ~ m_users[i + 1 .. $];
                return true;
            }
        }
        return false;
    }

private:
    void seed() {
        m_users ~= AdminUser(
            "1",
            "administrator",
            "admin@example.com",
            "Admin",
            true,
            Clock.currTime().toISOString()
        );
        m_users ~= AdminUser(
            "2",
            "procurement.manager",
            "buyer@example.com",
            "Manager",
            true,
            Clock.currTime().toISOString()
        );
        m_users ~= AdminUser(
            "3",
            "auditor",
            "audit@example.com",
            "Viewer",
            false,
            Clock.currTime().toISOString()
        );
        m_nextId = 4;
    }
}
