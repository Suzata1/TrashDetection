import userModel from "../models/user.model.js";

// ================= DASHBOARD STATS =================
export const getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await userModel.countDocuments();
    
    // Mocking the eco-metrics for now until the actual models are built
    const totalRecycledWastes = 12450; // kg
    const totalCarbonEmission = 8300; // kg CO2 saved
    const totalRewardsEarned = 45200; // points

    // Recent 5 users
    const recentUsers = await userModel
      .find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select("-password");

    return res.json({
      message: "Dashboard stats fetched",
      stats: {
        totalUsers,
        totalRecycledWastes,
        totalCarbonEmission,
        totalRewardsEarned,
      },
      recentUsers,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};
