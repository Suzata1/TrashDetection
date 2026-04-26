import React, { useEffect, useState } from "react";
import DashboardLayout from "../components/DashboardLayout";
import API from "../api";
import toast from "react-hot-toast";
import { FiSearch, FiTrash2, FiChevronLeft, FiChevronRight } from "react-icons/fi";

interface User {
  _id: string;
  name: string;
  email: string;
  role: string;
  createdAt: string;
}

const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const perPage = 10;

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const res = await API.get("/users");
      setUsers(res.data.users);
    } catch {
      toast.error("Failed to load users");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!window.confirm(`Are you sure you want to delete "${name}"?`)) return;

    try {
      await API.delete(`/users/${id}`);
      toast.success("User deleted");
      setUsers((prev) => prev.filter((u) => u._id !== id));
    } catch {
      toast.error("Failed to delete user");
    }
  };

  const filtered = users.filter(
    (u) =>
      u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase())
  );

  const totalPages = Math.ceil(filtered.length / perPage);
  const paginated = filtered.slice((currentPage - 1) * perPage, currentPage * perPage);

  return (
    <DashboardLayout>
      <div className="animate-fade-in">
        {/* Header */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            marginBottom: "28px",
            flexWrap: "wrap",
            gap: "16px",
          }}
        >
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: 700, marginBottom: "4px" }}>Users</h1>
            <p style={{ color: "var(--color-text-muted)", fontSize: "14px" }}>
              Manage all registered users
            </p>
          </div>

          {/* Search */}
          <div style={{ position: "relative", minWidth: "260px" }}>
            <FiSearch
              size={18}
              style={{
                position: "absolute",
                left: "14px",
                top: "50%",
                transform: "translateY(-50%)",
                color: "var(--color-text-muted)",
              }}
            />
            <input
              id="users-search"
              type="text"
              placeholder="Search users..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setCurrentPage(1);
              }}
              style={{
                width: "100%",
                padding: "10px 14px 10px 44px",
                background: "var(--color-bg-card)",
                border: "1px solid var(--color-border)",
                borderRadius: "var(--radius-sm)",
                color: "var(--color-text-primary)",
                fontSize: "14px",
                outline: "none",
                transition: "border-color var(--transition-fast)",
              }}
              onFocus={(e) => (e.target.style.borderColor = "var(--color-primary)")}
              onBlur={(e) => (e.target.style.borderColor = "var(--color-border)")}
            />
          </div>
        </div>

        {/* Users Table */}
        <div className="glass-card" style={{ overflow: "hidden" }}>
          {loading ? (
            <div
              style={{
                padding: "60px",
                textAlign: "center",
                color: "var(--color-text-muted)",
              }}
            >
              Loading users...
            </div>
          ) : (
            <>
              <div style={{ overflowX: "auto" }}>
                <table
                  style={{
                    width: "100%",
                    borderCollapse: "collapse",
                    fontSize: "14px",
                  }}
                >
                  <thead>
                    <tr>
                      {["User", "Email", "Role", "Joined", "Actions"].map((h) => (
                        <th
                          key={h}
                          style={{
                            textAlign: "left",
                            padding: "14px 20px",
                            color: "var(--color-text-muted)",
                            fontWeight: 500,
                            fontSize: "12px",
                            textTransform: "uppercase",
                            letterSpacing: "0.05em",
                            borderBottom: "1px solid var(--color-border)",
                            background: "var(--color-bg-sidebar)",
                          }}
                        >
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {paginated.map((user) => (
                      <tr
                        key={user._id}
                        style={{ transition: "background var(--transition-fast)" }}
                        onMouseEnter={(e) =>
                          (e.currentTarget.style.background = "rgba(148, 163, 184, 0.04)")
                        }
                        onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                      >
                        <td
                          style={{
                            padding: "14px 20px",
                            borderBottom: "1px solid var(--color-border)",
                          }}
                        >
                          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                            <div
                              style={{
                                width: "36px",
                                height: "36px",
                                borderRadius: "50%",
                                background: "var(--gradient-primary)",
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "center",
                                fontSize: "15px",
                                fontWeight: 600,
                                color: "#fff",
                                flexShrink: 0,
                              }}
                            >
                              {user.name.charAt(0).toUpperCase()}
                            </div>
                            <span style={{ fontWeight: 500 }}>{user.name}</span>
                          </div>
                        </td>
                        <td
                          style={{
                            padding: "14px 20px",
                            borderBottom: "1px solid var(--color-border)",
                            color: "var(--color-text-secondary)",
                          }}
                        >
                          {user.email}
                        </td>
                        <td
                          style={{
                            padding: "14px 20px",
                            borderBottom: "1px solid var(--color-border)",
                          }}
                        >
                          <span
                            style={{
                              padding: "4px 10px",
                              borderRadius: "var(--radius-sm)",
                              fontSize: "12px",
                              fontWeight: 500,
                              background:
                                user.role === "admin"
                                  ? "rgba(139, 92, 246, 0.15)"
                                  : "rgba(16, 185, 129, 0.15)",
                              color: user.role === "admin" ? "#a78bfa" : "#34d399",
                            }}
                          >
                            {user.role}
                          </span>
                        </td>
                        <td
                          style={{
                            padding: "14px 20px",
                            borderBottom: "1px solid var(--color-border)",
                            color: "var(--color-text-muted)",
                            fontSize: "13px",
                          }}
                        >
                          {new Date(user.createdAt).toLocaleDateString("en-US", {
                            month: "short",
                            day: "numeric",
                            year: "numeric",
                          })}
                        </td>
                        <td
                          style={{
                            padding: "14px 20px",
                            borderBottom: "1px solid var(--color-border)",
                          }}
                        >
                          <button
                            onClick={() => handleDelete(user._id, user.name)}
                            style={{
                              padding: "6px 12px",
                              borderRadius: "var(--radius-sm)",
                              background: "rgba(239, 68, 68, 0.1)",
                              color: "var(--color-danger)",
                              border: "none",
                              cursor: "pointer",
                              fontSize: "13px",
                              fontWeight: 500,
                              display: "flex",
                              alignItems: "center",
                              gap: "6px",
                              transition: "background var(--transition-fast)",
                            }}
                            onMouseEnter={(e) =>
                              (e.currentTarget.style.background = "rgba(239, 68, 68, 0.2)")
                            }
                            onMouseLeave={(e) =>
                              (e.currentTarget.style.background = "rgba(239, 68, 68, 0.1)")
                            }
                          >
                            <FiTrash2 size={14} /> Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                    {paginated.length === 0 && (
                      <tr>
                        <td
                          colSpan={5}
                          style={{
                            padding: "50px 20px",
                            textAlign: "center",
                            color: "var(--color-text-muted)",
                          }}
                        >
                          {search ? "No users match your search" : "No users found"}
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "16px 20px",
                    borderTop: "1px solid var(--color-border)",
                  }}
                >
                  <span style={{ fontSize: "13px", color: "var(--color-text-muted)" }}>
                    Showing {(currentPage - 1) * perPage + 1}–
                    {Math.min(currentPage * perPage, filtered.length)} of {filtered.length}
                  </span>
                  <div style={{ display: "flex", gap: "8px" }}>
                    <button
                      onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                      disabled={currentPage === 1}
                      style={{
                        padding: "8px 12px",
                        borderRadius: "var(--radius-sm)",
                        background: "var(--color-bg-input)",
                        border: "1px solid var(--color-border)",
                        color:
                          currentPage === 1
                            ? "var(--color-text-muted)"
                            : "var(--color-text-primary)",
                        cursor: currentPage === 1 ? "not-allowed" : "pointer",
                        fontSize: "13px",
                        display: "flex",
                        alignItems: "center",
                        gap: "4px",
                      }}
                    >
                      <FiChevronLeft size={16} /> Prev
                    </button>
                    <button
                      onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                      disabled={currentPage === totalPages}
                      style={{
                        padding: "8px 12px",
                        borderRadius: "var(--radius-sm)",
                        background: "var(--color-bg-input)",
                        border: "1px solid var(--color-border)",
                        color:
                          currentPage === totalPages
                            ? "var(--color-text-muted)"
                            : "var(--color-text-primary)",
                        cursor: currentPage === totalPages ? "not-allowed" : "pointer",
                        fontSize: "13px",
                        display: "flex",
                        alignItems: "center",
                        gap: "4px",
                      }}
                    >
                      Next <FiChevronRight size={16} />
                    </button>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
};

export default UsersPage;
