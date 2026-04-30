
import userModel from "../models/user.model.js";


// ================= GET CURRENT USER (from JWT) =================
export const getMe = async (req, res) => {
  try {
    const user = await userModel.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.json({ user });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= GET ALL USERS =================
export const getAllUsers = async (req, res) => {
  try {
    const users = await userModel.find();

    return res.json({
      message: "Users fetched",
      users,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= GET SINGLE USER =================
export const getUserById = async (req, res) => {
  try {
    const user = await userModel.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.json({ user });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= UPDATE USER =================
export const updateUser = async (req, res) => {
  try {
    const user = await userModel.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    return res.json({
      message: "User updated",
      user,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= DELETE USER =================
export const deleteUser = async (req, res) => {
  try {
    await userModel.findByIdAndDelete(req.params.id);

    return res.json({
      message: "User deleted",
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= REDEEM CREDITS =================
export const redeemCredits = async (req, res) => {
  try {
    const { amount } = req.body;
    
    if (!amount || amount <= 0) {
      return res.status(400).json({ message: "Invalid amount" });
    }

    const user = await userModel.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.credits < amount) {
      return res.status(400).json({ message: "Insufficient credits" });
    }

    user.credits -= amount;
    await user.save();

    return res.json({
      message: `Successfully redeemed ${amount} Rs. via eSewa.`,
      user
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// // ================= Rest password =================



// export const resetPasswordWithOtp = async (req, res) => {
//   try {
//     const { email, otp, password } = req.body;

//     const user = await userModel.findOne({ email });

//     if (!user) {
//       return res.status(400).json({ message: "User not found" });
//     }

//     // Convert both to string for safe comparison
//     if (
//       String(user.otp) !== String(otp) ||
//       user.otpExpires < Date.now()
//     ) {
//       return res.status(400).json({ message: "Invalid or expired OTP" });
//     }

//     // Hash new password
//     const hashedPassword = await bcrypt.hash(password, 10);

//     user.password = hashedPassword;
//     user.otp = undefined;
//     user.otpExpires = undefined;

//     await user.save();

//     return res.json({
//       message: "Password reset successful",
//     });
//   } catch (err) {
//     return res.status(500).json({ message: err.message });
//   }
// };

// ================= LEADERBOARD =================
export const getLeaderboard = async (req, res) => {
  try {
    const users = await userModel
      .find({ role: "user" })
      .sort({ credits: -1 })
      .limit(10)
      .select("name credits profilePicture");

    return res.json({
      message: "Leaderboard fetched",
      leaderboard: users,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};