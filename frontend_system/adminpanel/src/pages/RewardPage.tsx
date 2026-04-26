import React, { useEffect, useState } from "react";
import DashboardLayout from "../components/DashboardLayout";
import API from "../api";
import toast from "react-hot-toast";
import { FiSearch, FiGift, FiX, FiCheckCircle } from "react-icons/fi";
import { FaUserCircle } from "react-icons/fa";

interface User {
  _id: string;
  name: string;
  email: string;
  phone: string;
  credits: number;
}

const RewardPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  // Redeem Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [redeemAmount, setRedeemAmount] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      // For now we just fetch all users. In a real app we might only fetch users with role='user'
      const res = await API.get("/users");
      // Filter out admins if you only want to reward standard users
      const standardUsers = res.data.users.filter((u: any) => u.role !== "admin");
      setUsers(standardUsers);
    } catch {
      toast.error("Failed to load users");
    } finally {
      setLoading(false);
    }
  };

  const openRedeemModal = (user: User) => {
    setSelectedUser(user);
    setRedeemAmount("");
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedUser(null);
  };

  const handleRedeem = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedUser) return;

    const amount = Number(redeemAmount);
    if (isNaN(amount) || amount <= 0) {
      toast.error("Please enter a valid amount");
      return;
    }

    if (amount > selectedUser.credits) {
      toast.error("Amount exceeds user's available credits");
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await API.post(`/users/${selectedUser._id}/redeem`, { amount });
      toast.success(res.data.message || "Redemption successful!");
      
      // Update the user's credits locally
      setUsers((prev) =>
        prev.map((u) =>
          u._id === selectedUser._id ? { ...u, credits: u.credits - amount } : u
        )
      );
      handleCloseModal();
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Failed to redeem credits");
    } finally {
      setIsSubmitting(false);
    }
  };

  const filtered = users.filter(
    (u) =>
      u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      (u.phone && u.phone.includes(search))
  );

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
            <h1 style={{ fontSize: "28px", fontWeight: 700, marginBottom: "4px" }}>Rewards & Redemption</h1>
            <p style={{ color: "var(--color-text-muted)", fontSize: "14px" }}>
              Manage user credits and process eSewa payouts
            </p>
          </div>

          <div style={{ display: "flex", gap: "16px" }}>
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
                type="text"
                placeholder="Search users..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
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
                    {["User", "Email", "Phone", "Credits Balance", "Actions"].map((h) => (
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
                  {filtered.map((user) => (
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
                              background: "rgba(139, 92, 246, 0.15)",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "center",
                              color: "#8b5cf6",
                              flexShrink: 0,
                            }}
                          >
                            <FaUserCircle size={20} />
                          </div>
                          <span style={{ fontWeight: 500, color: "var(--color-text-primary)" }}>{user.name}</span>
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
                          color: "var(--color-text-secondary)",
                        }}
                      >
                        {user.phone || "-"}
                      </td>
                      <td
                        style={{
                          padding: "14px 20px",
                          borderBottom: "1px solid var(--color-border)",
                        }}
                      >
                        <span
                          style={{
                            display: "inline-block",
                            padding: "4px 10px",
                            borderRadius: "var(--radius-xl)",
                            fontSize: "13px",
                            fontWeight: 600,
                            background: "rgba(16, 185, 129, 0.1)",
                            color: "var(--color-primary)",
                          }}
                        >
                          {user.credits} Rs
                        </span>
                      </td>
                      <td
                        style={{
                          padding: "14px 20px",
                          borderBottom: "1px solid var(--color-border)",
                        }}
                      >
                        <button
                          onClick={() => openRedeemModal(user)}
                          disabled={user.credits <= 0}
                          style={{
                            padding: "6px 14px",
                            borderRadius: "var(--radius-sm)",
                            background: user.credits > 0 ? "rgba(139, 92, 246, 0.1)" : "var(--color-bg-sidebar)",
                            color: user.credits > 0 ? "#8b5cf6" : "var(--color-text-muted)",
                            border: "none",
                            cursor: user.credits > 0 ? "pointer" : "not-allowed",
                            fontSize: "13px",
                            fontWeight: 600,
                            display: "flex",
                            alignItems: "center",
                            gap: "6px",
                            transition: "background var(--transition-fast)",
                          }}
                          onMouseEnter={(e) => {
                            if (user.credits > 0) e.currentTarget.style.background = "rgba(139, 92, 246, 0.2)";
                          }}
                          onMouseLeave={(e) => {
                            if (user.credits > 0) e.currentTarget.style.background = "rgba(139, 92, 246, 0.1)";
                          }}
                        >
                          <FiGift size={14} /> Redeem
                        </button>
                      </td>
                    </tr>
                  ))}
                  {filtered.length === 0 && (
                    <tr>
                      <td
                        colSpan={5}
                        style={{
                          padding: "50px 20px",
                          textAlign: "center",
                          color: "var(--color-text-muted)",
                        }}
                      >
                        {search ? "No users match your search" : "No regular users found."}
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Redeem Modal Overlay */}
      {isModalOpen && selectedUser && (
        <div
          className="animate-fade-in"
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: "rgba(15, 23, 42, 0.7)",
            backdropFilter: "blur(4px)",
            zIndex: 100,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            padding: "20px",
          }}
          onClick={handleCloseModal}
        >
          {/* Modal Content */}
          <div
            className="glass-card animate-fade-in-up"
            style={{
              width: "100%",
              maxWidth: "420px",
              background: "var(--color-bg-card)",
              boxShadow: "0 20px 40px rgba(0,0,0,0.15)",
              overflow: "hidden"
            }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div
              style={{
                background: "rgba(16, 185, 129, 0.05)",
                padding: "24px",
                borderBottom: "1px solid var(--color-border)",
                position: "relative"
              }}
            >
              <button
                onClick={handleCloseModal}
                style={{
                  position: "absolute",
                  top: "16px",
                  right: "16px",
                  background: "transparent",
                  border: "none",
                  color: "var(--color-text-muted)",
                  cursor: "pointer",
                  padding: "4px",
                  borderRadius: "var(--radius-sm)",
                  transition: "background 0.2s",
                }}
                onMouseEnter={(e) => (e.currentTarget.style.background = "rgba(0,0,0,0.05)")}
                onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
              >
                <FiX size={20} />
              </button>
              
              <div style={{ textAlign: "center" }}>
                <div style={{ 
                  width: "56px", 
                  height: "56px", 
                  borderRadius: "50%", 
                  background: "rgba(16, 185, 129, 0.15)",
                  color: "var(--color-primary)",
                  display: "flex", 
                  alignItems: "center", 
                  justifyContent: "center",
                  margin: "0 auto 12px"
                }}>
                  <FiGift size={28} />
                </div>
                <h2 style={{ fontSize: "20px", fontWeight: 700, color: "var(--color-text-primary)", marginBottom: "4px" }}>
                  Redeem Credits
                </h2>
                <p style={{ fontSize: "14px", color: "var(--color-text-secondary)" }}>
                  for {selectedUser.name}
                </p>
              </div>
            </div>

            <form onSubmit={handleRedeem} style={{ padding: "24px" }}>
              {/* Info Box */}
              <div style={{ 
                background: "var(--color-bg-sidebar)", 
                padding: "16px", 
                borderRadius: "var(--radius-sm)",
                border: "1px solid var(--color-border)",
                marginBottom: "24px",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center"
              }}>
                <span style={{ fontSize: "13px", color: "var(--color-text-secondary)", fontWeight: 500 }}>Available Balance</span>
                <span style={{ fontSize: "18px", color: "var(--color-primary)", fontWeight: 700 }}>Rs. {selectedUser.credits}</span>
              </div>

              {/* Amount Input */}
              <div style={{ marginBottom: "24px" }}>
                <label
                  style={{
                    display: "block",
                    fontSize: "13px",
                    fontWeight: 500,
                    color: "var(--color-text-secondary)",
                    marginBottom: "8px",
                  }}
                >
                  Amount to Redeem (Rs.)
                </label>
                <div style={{ position: "relative" }}>
                  <span style={{ 
                    position: "absolute", 
                    left: "14px", 
                    top: "50%", 
                    transform: "translateY(-50%)",
                    color: "var(--color-text-muted)",
                    fontWeight: 500
                  }}>Rs.</span>
                  <input
                    type="number"
                    required
                    min="1"
                    max={selectedUser.credits}
                    value={redeemAmount}
                    onChange={(e) => setRedeemAmount(e.target.value)}
                    placeholder="0.00"
                    style={{
                      width: "100%",
                      padding: "12px 14px 12px 40px",
                      background: "var(--color-bg-input)",
                      border: "1px solid var(--color-border)",
                      borderRadius: "var(--radius-sm)",
                      color: "var(--color-text-primary)",
                      fontSize: "16px",
                      fontWeight: 600,
                      outline: "none",
                      transition: "border-color var(--transition-fast)",
                    }}
                    onFocus={(e) => (e.target.style.borderColor = "var(--color-primary)")}
                    onBlur={(e) => (e.target.style.borderColor = "var(--color-border)")}
                  />
                </div>
              </div>

              {/* Form Actions */}
              <button
                type="submit"
                disabled={isSubmitting || !redeemAmount}
                style={{
                  width: "100%",
                  padding: "14px",
                  background: isSubmitting ? "var(--color-text-muted)" : "#60a839", // eSewa brand color
                  color: "#fff",
                  border: "none",
                  borderRadius: "var(--radius-sm)",
                  cursor: isSubmitting || !redeemAmount ? "not-allowed" : "pointer",
                  fontSize: "15px",
                  fontWeight: 600,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  gap: "8px",
                  boxShadow: isSubmitting ? "none" : "0 4px 12px rgba(96, 168, 57, 0.3)",
                  transition: "transform 0.2s, box-shadow 0.2s",
                }}
                onMouseEnter={(e) => {
                  if (!isSubmitting && redeemAmount) {
                    e.currentTarget.style.transform = "translateY(-2px)";
                    e.currentTarget.style.boxShadow = "0 6px 16px rgba(96, 168, 57, 0.4)";
                  }
                }}
                onMouseLeave={(e) => {
                  if (!isSubmitting && redeemAmount) {
                    e.currentTarget.style.transform = "translateY(0)";
                    e.currentTarget.style.boxShadow = "0 4px 12px rgba(96, 168, 57, 0.3)";
                  }
                }}
              >
                {isSubmitting ? "Processing..." : (
                  <>
                    <FiCheckCircle size={18} /> Pay with eSewa
                  </>
                )}
              </button>
              
              <p style={{ textAlign: "center", marginTop: "16px", fontSize: "12px", color: "var(--color-text-muted)" }}>
                This will simulate an eSewa payout and deduct the user's credits.
              </p>
            </form>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
};

export default RewardPage;
