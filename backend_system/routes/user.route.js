import express from "express";
import authentication from "../middleware/authMiddleware.js";
import { Role } from "../middleware/authrole.Middleware.js";
import {
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  redeemCredits,
  getMe,
  getLeaderboard,
} from "../controllers/user.controller.js";

const router = express.Router();

// Mobile app: get current user profile via JWT
router.get("/me", authentication, getMe);

// Mobile app: get leaderboard
router.get("/leaderboard", authentication, getLeaderboard);

// Admin: get all users
router.get("/", authentication, Role("admin"), getAllUsers);

// Get single user
router.get("/:id", authentication, getUserById);

// Update user (self or admin)
router.put("/:id", authentication, updateUser);

// Admin: delete user
router.delete("/:id", authentication, Role("admin"), deleteUser);

// Admin: redeem credits
router.post("/:id/redeem", authentication, Role("admin"), redeemCredits);

export default router;