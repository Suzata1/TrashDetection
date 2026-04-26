import React, { useState } from "react";
import Sidebar from "./Sidebar";

interface DashboardLayoutProps {
  children: React.ReactNode;
}

const DashboardLayout: React.FC<DashboardLayoutProps> = ({ children }) => {
  const [sidebarWidth] = useState(260);

  return (
    <div style={{ display: "flex", minHeight: "100vh" }}>
      <Sidebar />
      <main
        style={{
          marginLeft: `${sidebarWidth}px`,
          flex: 1,
          minHeight: "100vh",
          background: "var(--color-bg-dark)",
          transition: "margin-left var(--transition-normal)",
          padding: "32px",
          overflowX: "hidden",
        }}
      >
        {children}
      </main>
    </div>
  );
};

export default DashboardLayout;
