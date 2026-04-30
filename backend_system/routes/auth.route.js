import express from "express";
import {
  login,
  register,
  forgotPassword,
  resetPassword,
  changePassword,
} from "../controllers/authController.js";
import authentication from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/login", login);
router.post("/register", register);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password/:token", resetPassword);
router.post("/change-password", authentication, changePassword);

export default router;