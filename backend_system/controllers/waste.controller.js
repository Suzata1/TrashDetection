import wasteScanModel from "../models/waste.model.js";
import userModel from "../models/user.model.js";

// Credit values per waste type (in Rs.)
const CREDIT_MAP = {
  cardboard: 2,
  glass: 4,
  metal: 5,
  paper: 1,
  plastic: 3,
  trash: 1,
};

// Approximate CO2 savings per waste type (in grams)
const CO2_MAP = {
  cardboard: 150,
  glass: 200,
  metal: 300,
  paper: 100,
  plastic: 250,
  trash: 50,
};

// ================= SCAN WASTE & EARN CREDITS =================
export const scanWaste = async (req, res) => {
  try {
    const { wasteType, confidence } = req.body;
    const userId = req.user.id; // from auth middleware

    if (!wasteType || confidence === undefined) {
      return res.status(400).json({ message: "wasteType and confidence are required" });
    }

    const normalizedType = wasteType.toLowerCase();

    if (!CREDIT_MAP[normalizedType]) {
      return res.status(400).json({ message: `Invalid waste type: ${wasteType}` });
    }

    const creditsEarned = CREDIT_MAP[normalizedType];
    const co2Saved = CO2_MAP[normalizedType];

    // 1. Create a scan record
    const scan = await wasteScanModel.create({
      user: userId,
      wasteType: normalizedType,
      confidence,
      creditsEarned,
      co2Saved,
    });

    // 2. Add credits to the user's balance
    const user = await userModel.findByIdAndUpdate(
      userId,
      { $inc: { credits: creditsEarned } },
      { new: true }
    );

    return res.status(201).json({
      message: `You earned Rs. ${creditsEarned} for recycling ${normalizedType}!`,
      scan,
      updatedCredits: user.credits,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= GET USER SCAN HISTORY =================
export const getScanHistory = async (req, res) => {
  try {
    const userId = req.user.id;

    const scans = await wasteScanModel
      .find({ user: userId })
      .sort({ createdAt: -1 })
      .limit(50);

    return res.json({
      message: "Scan history fetched",
      scans,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= GET SCAN STATS (for dashboard) =================
export const getScanStats = async (req, res) => {
  try {
    const userId = req.user.id;

    const stats = await wasteScanModel.aggregate([
      { $match: { user: userId } },
      {
        $group: {
          _id: null,
          totalScans: { $sum: 1 },
          totalCreditsEarned: { $sum: "$creditsEarned" },
          totalCo2Saved: { $sum: "$co2Saved" },
        },
      },
    ]);

    return res.json({
      message: "Scan stats fetched",
      stats: stats[0] || { totalScans: 0, totalCreditsEarned: 0, totalCo2Saved: 0 },
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};
