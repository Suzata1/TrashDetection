import React, { useState } from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import {
  FiGrid,
  FiUsers,
  FiMapPin,
  FiGift,
  FiLogOut,
  FiChevronLeft,
  FiChevronRight,
} from "react-icons/fi";
import { FaHandshake } from "react-icons/fa";

const navItems = [
  { to: "/dashboard", icon: FiGrid, label: "Dashboard" },
  { to: "/users", icon: FiUsers, label: "Users" },
  { to: "/partners", icon: FaHandshake, label: "Partners" },
  { to: "/locations", icon: FiMapPin, label: "Locations" },
  { to: "/rewards", icon: FiGift, label: "Rewards" },
];

const Sidebar: React.FC = () => {
  const [collapsed, setCollapsed] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/");
  };

  return (
    <aside
      style={{
        width: collapsed ? "72px" : "260px",
        minHeight: "100vh",
        background: "var(--color-bg-sidebar)",
        borderRight: "1px solid var(--color-border)",
        display: "flex",
        flexDirection: "column",
        transition: "width var(--transition-normal)",
        position: "fixed",
        top: 0,
        left: 0,
        zIndex: 50,
        overflow: "hidden",
      }}
    >
      {/* Logo Area */}
      <div
        style={{
          padding: collapsed ? "20px 12px" : "20px 24px",
          borderBottom: "1px solid var(--color-border)",
          display: "flex",
          alignItems: "center",
          gap: "12px",
          minHeight: "72px",
        }}
      >
        <div
          style={{
            width: "36px",
            height: "36px",
            borderRadius: "var(--radius-sm)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            flexShrink: 0,
            overflow: "hidden",
          }}
        >
          <img
            src="/logo1.png"
            alt="EcoAdmin"
            style={{
              width: "36px",
              height: "36px",
              objectFit: "contain",
            }}
          />
        </div>
        {!collapsed && (
          <span
            style={{
              fontSize: "16px",
              fontWeight: 700,
              color: "var(--color-text-primary)",
              whiteSpace: "nowrap",
            }}
          >
            EcoAdmin
          </span>
        )}
      </div>

      {/* Nav Items */}
      <nav style={{ flex: 1, padding: "16px 8px", display: "flex", flexDirection: "column", gap: "4px" }}>
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            style={({ isActive }) => ({
              display: "flex",
              alignItems: "center",
              gap: "12px",
              padding: collapsed ? "12px 16px" : "12px 16px",
              borderRadius: "var(--radius-sm)",
              color: isActive ? "var(--color-primary)" : "var(--color-text-secondary)",
              background: isActive ? "rgba(16, 185, 129, 0.1)" : "transparent",
              fontWeight: isActive ? 600 : 400,
              fontSize: "14px",
              transition: "all var(--transition-fast)",
              textDecoration: "none",
              whiteSpace: "nowrap",
              position: "relative",
              overflow: "hidden",
            })}
            onMouseEnter={(e) => {
              const target = e.currentTarget;
              if (!target.classList.contains("active")) {
                target.style.background = "rgba(148, 163, 184, 0.08)";
              }
            }}
            onMouseLeave={(e) => {
              const target = e.currentTarget;
              if (!target.classList.contains("active")) {
                target.style.background = "transparent";
              }
            }}
          >
            <item.icon size={20} style={{ flexShrink: 0 }} />
            {!collapsed && <span>{item.label}</span>}
          </NavLink>
        ))}
      </nav>

      {/* User Info + Logout */}
      <div
        style={{
          padding: collapsed ? "16px 8px" : "16px",
          borderTop: "1px solid var(--color-border)",
          display: "flex",
          flexDirection: "column",
          gap: "12px",
        }}
      >
        {!collapsed && user && (
          <div style={{ padding: "0 8px" }}>
            <p
              style={{
                fontSize: "13px",
                fontWeight: 600,
                color: "var(--color-text-primary)",
                marginBottom: "2px",
              }}
            >
              {user.name}
            </p>
            <p style={{ fontSize: "11px", color: "var(--color-text-muted)" }}>{user.email}</p>
          </div>
        )}
        <button
          onClick={handleLogout}
          style={{
            display: "flex",
            alignItems: "center",
            gap: "12px",
            padding: "10px 16px",
            borderRadius: "var(--radius-sm)",
            color: "var(--color-danger)",
            background: "rgba(239, 68, 68, 0.08)",
            border: "none",
            cursor: "pointer",
            fontSize: "14px",
            fontWeight: 500,
            transition: "all var(--transition-fast)",
            width: "100%",
          }}
          onMouseEnter={(e) => (e.currentTarget.style.background = "rgba(239, 68, 68, 0.15)")}
          onMouseLeave={(e) => (e.currentTarget.style.background = "rgba(239, 68, 68, 0.08)")}
        >
          <FiLogOut size={18} style={{ flexShrink: 0 }} />
          {!collapsed && <span>Logout</span>}
        </button>
      </div>

      {/* Collapse Toggle */}
      <button
        onClick={() => setCollapsed(!collapsed)}
        style={{
          position: "absolute",
          top: "20px",
          right: "5px",
          width: "28px",
          height: "28px",
          borderRadius: "50%",
          background: "var(--color-bg-card)",
          border: "1px solid var(--color-border)",
          color: "var(--color-text-secondary)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
          transition: "all var(--transition-fast)",
          zIndex: 51,
        }}
        onMouseEnter={(e) => {
          e.currentTarget.style.borderColor = "var(--color-primary)";
          e.currentTarget.style.color = "var(--color-primary)";
        }}
        onMouseLeave={(e) => {
          e.currentTarget.style.borderColor = "var(--color-border)";
          e.currentTarget.style.color = "var(--color-text-secondary)";
        }}
      >
        {collapsed ? <FiChevronRight size={14} /> : <FiChevronLeft size={14} />}
      </button>
    </aside>
  );
};

export default Sidebar;
