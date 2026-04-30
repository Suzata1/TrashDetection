import express from "express";
import {
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  redeemCredits,
} from "../controllers/user.controller.js";

const router = express.Router();

router.get("/", getAllUsers);
router.get("/:id", getUserById);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);
router.post("/:id/redeem", redeemCredits);
// router.post("/send-otp", sendOtp);
// router.post("/verify-otp", verifyOtp);
// router.post("/reset-password-otp", resetPasswordWithOtp);

export default router;