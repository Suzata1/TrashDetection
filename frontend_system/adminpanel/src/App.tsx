// src/App.tsx
import React from "react";
import { Routes, Route } from "react-router-dom";
import LoginPage from "./components/LoginPage";
import SignupPage from "./components/SignUp";
import DashboardPage from "./pages/DashboardPage";
import PartnersPage from "./pages/PartnerPage";
import LocationPage from "./pages/LocationPage";
import RewardsPage from "./pages/RewardPage";




const App: React.FC = () => {
  return (
    <>
        <Routes>
            <Route path="/rewards" element={<RewardsPage />} />
          <Route path="/locations" element={<LocationPage />} />
          <Route path="/partners" element={<PartnersPage />} />
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
        </Routes>
     
    </>
  );
};

export default App;
