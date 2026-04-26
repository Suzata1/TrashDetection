import React, { useEffect, useState } from "react";
import DashboardLayout from "../components/DashboardLayout";
import API from "../api";
import toast from "react-hot-toast";
import { FiSearch, FiTrash2, FiEdit2, FiPlus, FiX } from "react-icons/fi";
import { FaHandshake } from "react-icons/fa";

interface Partner {
  _id: string;
  name: string;
  email: string;
  phone: string;
  createdAt: string;
}

const PartnerPage: React.FC = () => {
  const [partners, setPartners] = useState<Partner[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  
  // Modal state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingPartner, setEditingPartner] = useState<Partner | null>(null);
  
  // Form state
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchPartners();
  }, []);

  const fetchPartners = async () => {
    try {
      const res = await API.get("/partners");
      setPartners(res.data.partners);
    } catch {
      toast.error("Failed to load partners");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!window.confirm(`Are you sure you want to delete partner "${name}"?`)) return;

    try {
      await API.delete(`/partners/${id}`);
      toast.success("Partner deleted");
      setPartners((prev) => prev.filter((p) => p._id !== id));
    } catch {
      toast.error("Failed to delete partner");
    }
  };

  const openAddModal = () => {
    setEditingPartner(null);
    setFormData({ name: "", email: "", phone: "" });
    setIsModalOpen(true);
  };

  const openEditModal = (partner: Partner) => {
    setEditingPartner(partner);
    setFormData({
      name: partner.name,
      email: partner.email,
      phone: partner.phone || "",
    });
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingPartner(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name || !formData.email) {
      toast.error("Name and Email are required");
      return;
    }

    setIsSubmitting(true);
    try {
      if (editingPartner) {
        // Edit
        const res = await API.put(`/partners/${editingPartner._id}`, formData);
        toast.success("Partner updated");
        setPartners((prev) =>
          prev.map((p) => (p._id === editingPartner._id ? res.data.partner : p))
        );
      } else {
        // Add
        const res = await API.post("/partners", formData);
        toast.success("Partner added");
        setPartners([res.data.partner, ...partners]);
      }
      handleCloseModal();
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Operation failed");
    } finally {
      setIsSubmitting(false);
    }
  };

  const filtered = partners.filter(
    (p) =>
      p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.email.toLowerCase().includes(search.toLowerCase())
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
            <h1 style={{ fontSize: "28px", fontWeight: 700, marginBottom: "4px" }}>Partners</h1>
            <p style={{ color: "var(--color-text-muted)", fontSize: "14px" }}>
              Manage recycling and collection partners
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
                placeholder="Search partners..."
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
            
            <button
              onClick={openAddModal}
              style={{
                display: "flex",
                alignItems: "center",
                gap: "8px",
                padding: "10px 16px",
                background: "var(--gradient-primary)",
                color: "#fff",
                border: "none",
                borderRadius: "var(--radius-sm)",
                cursor: "pointer",
                fontWeight: 600,
                fontSize: "14px",
                boxShadow: "0 4px 12px rgba(16, 185, 129, 0.2)",
                transition: "transform 0.2s, box-shadow 0.2s",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.transform = "translateY(-2px)";
                e.currentTarget.style.boxShadow = "0 6px 16px rgba(16, 185, 129, 0.3)";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.transform = "translateY(0)";
                e.currentTarget.style.boxShadow = "0 4px 12px rgba(16, 185, 129, 0.2)";
              }}
            >
              <FiPlus size={18} /> Add Partner
            </button>
          </div>
        </div>

        {/* Partners Table */}
        <div className="glass-card" style={{ overflow: "hidden" }}>
          {loading ? (
            <div
              style={{
                padding: "60px",
                textAlign: "center",
                color: "var(--color-text-muted)",
              }}
            >
              Loading partners...
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
                    {["Partner", "Email", "Phone", "Joined", "Actions"].map((h) => (
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
                  {filtered.map((partner) => (
                    <tr
                      key={partner._id}
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
                              background: "rgba(16, 185, 129, 0.15)",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "center",
                              color: "var(--color-primary)",
                              flexShrink: 0,
                            }}
                          >
                            <FaHandshake size={16} />
                          </div>
                          <span style={{ fontWeight: 500, color: "var(--color-text-primary)" }}>{partner.name}</span>
                        </div>
                      </td>
                      <td
                        style={{
                          padding: "14px 20px",
                          borderBottom: "1px solid var(--color-border)",
                          color: "var(--color-text-secondary)",
                        }}
                      >
                        {partner.email}
                      </td>
                      <td
                        style={{
                          padding: "14px 20px",
                          borderBottom: "1px solid var(--color-border)",
                          color: "var(--color-text-secondary)",
                        }}
                      >
                        {partner.phone || "-"}
                      </td>
                      <td
                        style={{
                          padding: "14px 20px",
                          borderBottom: "1px solid var(--color-border)",
                          color: "var(--color-text-muted)",
                          fontSize: "13px",
                        }}
                      >
                        {new Date(partner.createdAt).toLocaleDateString("en-US", {
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
                        <div style={{ display: "flex", gap: "8px" }}>
                          <button
                            onClick={() => openEditModal(partner)}
                            style={{
                              padding: "6px 12px",
                              borderRadius: "var(--radius-sm)",
                              background: "rgba(59, 130, 246, 0.1)",
                              color: "var(--color-info)",
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
                              (e.currentTarget.style.background = "rgba(59, 130, 246, 0.2)")
                            }
                            onMouseLeave={(e) =>
                              (e.currentTarget.style.background = "rgba(59, 130, 246, 0.1)")
                            }
                          >
                            <FiEdit2 size={14} /> Edit
                          </button>
                          <button
                            onClick={() => handleDelete(partner._id, partner.name)}
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
                        </div>
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
                        {search ? "No partners match your search" : "No partners found. Add one to get started!"}
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Modal Overlay */}
      {isModalOpen && (
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
              maxWidth: "500px",
              background: "var(--color-bg-card)",
              boxShadow: "0 20px 40px rgba(0,0,0,0.4)",
            }}
            onClick={(e) => e.stopPropagation()} // Prevent clicking inside modal from closing it
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "20px 24px",
                borderBottom: "1px solid var(--color-border)",
              }}
            >
              <h2 style={{ fontSize: "18px", fontWeight: 600 }}>
                {editingPartner ? "Edit Partner" : "Add New Partner"}
              </h2>
              <button
                onClick={handleCloseModal}
                style={{
                  background: "transparent",
                  border: "none",
                  color: "var(--color-text-muted)",
                  cursor: "pointer",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  padding: "4px",
                  borderRadius: "var(--radius-sm)",
                  transition: "background 0.2s",
                }}
                onMouseEnter={(e) => (e.currentTarget.style.background = "rgba(255,255,255,0.05)")}
                onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
              >
                <FiX size={20} />
              </button>
            </div>

            <form onSubmit={handleSubmit} style={{ padding: "24px" }}>
              <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                {/* Name Input */}
                <div>
                  <label
                    style={{
                      display: "block",
                      fontSize: "13px",
                      fontWeight: 500,
                      color: "var(--color-text-secondary)",
                      marginBottom: "8px",
                    }}
                  >
                    Partner Name <span style={{ color: "var(--color-danger)" }}>*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    placeholder="Enter partner name"
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "var(--color-bg-input)",
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

                {/* Email Input */}
                <div>
                  <label
                    style={{
                      display: "block",
                      fontSize: "13px",
                      fontWeight: 500,
                      color: "var(--color-text-secondary)",
                      marginBottom: "8px",
                    }}
                  >
                    Email Address <span style={{ color: "var(--color-danger)" }}>*</span>
                  </label>
                  <input
                    type="email"
                    required
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    placeholder="partner@example.com"
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "var(--color-bg-input)",
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

                {/* Phone Input */}
                <div>
                  <label
                    style={{
                      display: "block",
                      fontSize: "13px",
                      fontWeight: 500,
                      color: "var(--color-text-secondary)",
                      marginBottom: "8px",
                    }}
                  >
                    Phone Number (Optional)
                  </label>
                  <input
                    type="text"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    placeholder="+1 (555) 000-0000"
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "var(--color-bg-input)",
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

              {/* Form Actions */}
              <div
                style={{
                  display: "flex",
                  justifyContent: "flex-end",
                  gap: "12px",
                  marginTop: "32px",
                }}
              >
                <button
                  type="button"
                  onClick={handleCloseModal}
                  style={{
                    padding: "10px 16px",
                    background: "transparent",
                    border: "1px solid var(--color-border)",
                    color: "var(--color-text-primary)",
                    borderRadius: "var(--radius-sm)",
                    cursor: "pointer",
                    fontSize: "14px",
                    fontWeight: 500,
                    transition: "background 0.2s",
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = "rgba(255,255,255,0.05)")}
                  onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  style={{
                    padding: "10px 24px",
                    background: isSubmitting ? "var(--color-text-muted)" : "var(--gradient-primary)",
                    color: "#fff",
                    border: "none",
                    borderRadius: "var(--radius-sm)",
                    cursor: isSubmitting ? "not-allowed" : "pointer",
                    fontSize: "14px",
                    fontWeight: 600,
                    boxShadow: isSubmitting ? "none" : "0 4px 12px rgba(16, 185, 129, 0.2)",
                  }}
                >
                  {isSubmitting ? "Saving..." : editingPartner ? "Update Partner" : "Add Partner"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
};

export default PartnerPage;
