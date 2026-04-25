import userModel from "../models/user.model.js";

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