
import userModel from "../models/user.model.js";

export const Role = (role) => {
  return async (req, res, next) => {
    try {
      // Ensure auth middleware has run
      if (!req.user || !req.user.id) {
        return res.status(401).json({ message: "Unauthorized: No user logged in" });
      }

      const user = await userModel.findById(req.user.id);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      if (user.role === role) {
        return next(); // Role matches, continue
      } else {
        return res.status(403).json({ message: "Access denied for this role" });
      }
    } catch (err) {
      return res.status(500).json({ message: err.message || "Something went wrong!" });
    }
  };
};