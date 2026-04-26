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

export default router;