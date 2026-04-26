import React, { useEffect, useState } from "react";
import DashboardLayout from "../components/DashboardLayout";
import API from "../api";
import toast from "react-hot-toast";
import { FiSearch, FiTrash2, FiEdit2, FiPlus, FiX, FiMapPin } from "react-icons/fi";

interface Location {
  _id: string;
  vendorName: string;
  vendorAddress: string;
  status: "Active" | "Inactive";
  createdAt: string;
}

const LocationPage: React.FC = () => {
  const [locations, setLocations] = useState<Location[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  
  // Modal state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingLocation, setEditingLocation] = useState<Location | null>(null);
  
  // Form state
  const [formData, setFormData] = useState({
    vendorName: "",
    vendorAddress: "",
    status: "Active" as "Active" | "Inactive",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchLocations();
  }, []);

  const fetchLocations = async () => {
    try {
      const res = await API.get("/locations");
      setLocations(res.data.locations);
    } catch {
      toast.error("Failed to load locations");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!window.confirm(`Are you sure you want to delete location "${name}"?`)) return;

    try {
      await API.delete(`/locations/${id}`);
      toast.success("Location deleted");
      setLocations((prev) => prev.filter((loc) => loc._id !== id));
    } catch {
      toast.error("Failed to delete location");
    }
  };

  const openAddModal = () => {
    setEditingLocation(null);
    setFormData({ vendorName: "", vendorAddress: "", status: "Active" });
    setIsModalOpen(true);
  };

  const openEditModal = (location: Location) => {
    setEditingLocation(location);
    setFormData({
      vendorName: location.vendorName,
      vendorAddress: location.vendorAddress,
      status: location.status,
    });
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingLocation(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.vendorName || !formData.vendorAddress) {
      toast.error("Vendor Name and Address are required");
      return;
    }

    setIsSubmitting(true);
    try {
      if (editingLocation) {
        // Edit
        const res = await API.put(`/locations/${editingLocation._id}`, formData);
        toast.success("Location updated");
        setLocations((prev) =>
          prev.map((loc) => (loc._id === editingLocation._id ? res.data.location : loc))
        );
      } else {
        // Add
        const res = await API.post("/locations", formData);
        toast.success("Location added");
        setLocations([res.data.location, ...locations]);
      }
      handleCloseModal();
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Operation failed");
    } finally {
      setIsSubmitting(false);
    }
  };

  const filtered = locations.filter(
    (loc) =>
      loc.vendorName.toLowerCase().includes(search.toLowerCase()) ||
      loc.vendorAddress.toLowerCase().includes(search.toLowerCase())
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
            <h1 style={{ fontSize: "28px", fontWeight: 700, marginBottom: "4px" }}>Locations</h1>
            <p style={{ color: "var(--color-text-muted)", fontSize: "14px" }}>
              Manage trash collection and recycling locations
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
                placeholder="Search locations..."
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
              <FiPlus size={18} /> Add Location
            </button>
          </div>
        </div>

        {/* Locations Table */}
        <div className="glass-card" style={{ overflow: "hidden" }}>
          {loading ? (
            <div
              style={{
                padding: "60px",
                textAlign: "center",
                color: "var(--color-text-muted)",
              }}
            >
              Loading locations...
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
                    {["Vendor Name", "Address", "Status", "Added On", "Actions"].map((h) => (
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
                  {filtered.map((location) => (
                    <tr
                      key={location._id}
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
                              background: "rgba(59, 130, 246, 0.15)",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "center",
                              color: "#3b82f6",
                              flexShrink: 0,
                            }}
                          >
                            <FiMapPin size={16} />
                          </div>
                          <span style={{ fontWeight: 500, color: "var(--color-text-primary)" }}>{location.vendorName}</span>
                        </div>
                      </td>
                      <td
                        style={{
                          padding: "14px 20px",
                          borderBottom: "1px solid var(--color-border)",
                          color: "var(--color-text-secondary)",
                        }}
                      >
                        {location.vendorAddress}
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
                            fontSize: "12px",
                            fontWeight: 600,
                            background: location.status === "Active" ? "rgba(16, 185, 129, 0.1)" : "rgba(239, 68, 68, 0.1)",
                            color: location.status === "Active" ? "var(--color-primary)" : "var(--color-danger)",
                          }}
                        >
                          {location.status}
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
                        {new Date(location.createdAt).toLocaleDateString("en-US", {
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
                            onClick={() => openEditModal(location)}
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
                            onClick={() => handleDelete(location._id, location.vendorName)}
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
                        {search ? "No locations match your search" : "No locations found. Add one to get started!"}
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
            onClick={(e) => e.stopPropagation()}
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
                {editingLocation ? "Edit Location" : "Add New Location"}
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
                {/* Vendor Name */}
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
                    Vendor Name <span style={{ color: "var(--color-danger)" }}>*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.vendorName}
                    onChange={(e) => setFormData({ ...formData, vendorName: e.target.value })}
                    placeholder="Enter vendor name"
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

                {/* Vendor Address */}
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
                    Address <span style={{ color: "var(--color-danger)" }}>*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.vendorAddress}
                    onChange={(e) => setFormData({ ...formData, vendorAddress: e.target.value })}
                    placeholder="Enter full address"
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

                {/* Status */}
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
                    Status
                  </label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      background: "var(--color-bg-input)",
                      border: "1px solid var(--color-border)",
                      borderRadius: "var(--radius-sm)",
                      color: "var(--color-text-primary)",
                      fontSize: "14px",
                      outline: "none",
                      appearance: "none",
                      cursor: "pointer",
                      transition: "border-color var(--transition-fast)",
                    }}
                    onFocus={(e) => (e.target.style.borderColor = "var(--color-primary)")}
                    onBlur={(e) => (e.target.style.borderColor = "var(--color-border)")}
                  >
                    <option value="Active" style={{ background: "var(--color-bg-card)" }}>Active</option>
                    <option value="Inactive" style={{ background: "var(--color-bg-card)" }}>Inactive</option>
                  </select>
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
                  {isSubmitting ? "Saving..." : editingLocation ? "Update Location" : "Add Location"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
};

export default LocationPage;
