import React, { useEffect, useState } from "react";
import DashboardLayout from "../components/DashboardLayout";
import API from "../api";
import toast from "react-hot-toast";
import { FiUsers, FiTrash2, FiCloudLightning, FiGift } from "react-icons/fi";

interface Stats {
  totalUsers: number;
  totalRecycledWastes: number;
  totalCarbonEmission: number;
  totalRewardsEarned: number;
}

interface RecentUser {
  _id: string;
  name: string;
  email: string;
  role: string;
  createdAt: string;
}

const DashboardPage: React.FC = () => {
  const [stats, setStats] = useState<Stats | null>(null);
  const [recentUsers, setRecentUsers] = useState<RecentUser[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await API.get("/admin/stats");
        setStats(res.data.stats);
        setRecentUsers(res.data.recentUsers);
      } catch {
        toast.error("Failed to load dashboard data");
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  const statCards = stats
    ? [
        {
          label: "Total Users",
          value: stats.totalUsers,
          suffix: "",
          icon: FiUsers,
          color: "#3b82f6",
          bg: "rgba(59, 130, 246, 0.1)",
        },
        {
          label: "Total Recycled Wastes",
          value: stats.totalRecycledWastes,
          suffix: " kg",
          icon: FiTrash2,
          color: "#10b981",
          bg: "rgba(16, 185, 129, 0.1)",
        },
        {
          label: "Total Carbon Emission Saved",
          value: stats.totalCarbonEmission,
          suffix: " kg CO2",
          icon: FiCloudLightning,
          color: "#059669",
          bg: "rgba(5, 150, 105, 0.1)",
        },
        {
          label: "Total Rewards Earned",
          value: stats.totalRewardsEarned,
          suffix: " pts",
          icon: FiGift,
          color: "#8b5cf6",
          bg: "rgba(139, 92, 246, 0.1)",
        },
      ]
    : [];

  return (
    <DashboardLayout>
      <div className="animate-fade-in">
        {/* Page Header */}
        <div style={{ marginBottom: "32px" }}>
          <h1 style={{ fontSize: "28px", fontWeight: 700, marginBottom: "4px" }}>Dashboard</h1>
          <p style={{ color: "var(--color-text-muted)", fontSize: "14px" }}>
            Overview of your platform analytics
          </p>
        </div>

        {loading ? (
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              height: "300px",
              color: "var(--color-text-muted)",
              fontSize: "15px",
            }}
          >
            Loading dashboard data...
          </div>
        ) : (
          <>
            {/* Stats Grid */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
                gap: "20px",
                marginBottom: "36px",
              }}
            >
              {statCards.map((card, i) => (
                <div
                  key={card.label}
                  className="glass-card animate-fade-in-up"
                  style={{
                    padding: "24px",
                    animationDelay: `${i * 0.1}s`,
                    animationFillMode: "backwards",
                    cursor: "default",
                    transition: "transform var(--transition-fast), box-shadow var(--transition-fast)",
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.transform = "translateY(-4px)";
                    e.currentTarget.style.boxShadow = `0 8px 32px rgba(0,0,0,0.3)`;
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.transform = "translateY(0)";
                    e.currentTarget.style.boxShadow = "var(--shadow-card)";
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "space-between",
                      marginBottom: "16px",
                    }}
                  >
                    <span
                      style={{
                        fontSize: "13px",
                        fontWeight: 500,
                        color: "var(--color-text-secondary)",
                        textTransform: "uppercase",
                        letterSpacing: "0.05em",
                      }}
                    >
                      {card.label}
                    </span>
                    <div
                      style={{
                        width: "40px",
                        height: "40px",
                        borderRadius: "var(--radius-sm)",
                        background: card.bg,
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                      }}
                    >
                      <card.icon size={20} color={card.color} />
                    </div>
                  </div>
                  <p
                    style={{
                      fontSize: "32px",
                      fontWeight: 700,
                      color: "var(--color-text-primary)",
                      lineHeight: 1,
                    }}
                  >
                    {card.value.toLocaleString()}<span style={{ fontSize: "16px", color: "var(--color-text-muted)", marginLeft: "4px" }}>{card.suffix}</span>
                  </p>
                </div>
              ))}
            </div>

            {/* Recent Users Table */}
            <div className="glass-card" style={{ padding: "24px", overflow: "hidden" }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  marginBottom: "20px",
                }}
              >
                <h2 style={{ fontSize: "18px", fontWeight: 600 }}>Recent Users</h2>
                <span
                  style={{
                    fontSize: "12px",
                    color: "var(--color-text-muted)",
                    background: "var(--color-bg-input)",
                    padding: "4px 12px",
                    borderRadius: "var(--radius-sm)",
                  }}
                >
                  Last 5 signups
                </span>
              </div>

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
                      {["Name", "Email", "Role", "Joined"].map((header) => (
                        <th
                          key={header}
                          style={{
                            textAlign: "left",
                            padding: "12px 16px",
                            color: "var(--color-text-muted)",
                            fontWeight: 500,
                            fontSize: "12px",
                            textTransform: "uppercase",
                            letterSpacing: "0.05em",
                            borderBottom: "1px solid var(--color-border)",
                          }}
                        >
                          {header}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {recentUsers.map((user) => (
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
                            padding: "14px 16px",
                            borderBottom: "1px solid var(--color-border)",
                          }}
                        >
                          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                            <div
                              style={{
                                width: "34px",
                                height: "34px",
                                borderRadius: "50%",
                                background: "var(--gradient-primary)",
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "center",
                                fontSize: "14px",
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
                            padding: "14px 16px",
                            borderBottom: "1px solid var(--color-border)",
                            color: "var(--color-text-secondary)",
                          }}
                        >
                          {user.email}
                        </td>
                        <td
                          style={{
                            padding: "14px 16px",
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
                            padding: "14px 16px",
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
                      </tr>
                    ))}
                    {recentUsers.length === 0 && (
                      <tr>
                        <td
                          colSpan={4}
                          style={{
                            padding: "40px 16px",
                            textAlign: "center",
                            color: "var(--color-text-muted)",
                          }}
                        >
                          No users found
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      </div>
    </DashboardLayout>
  );
};

export default DashboardPage;
