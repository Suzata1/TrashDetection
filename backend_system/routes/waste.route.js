import express from "express";
import authentication from "../middleware/authMiddleware.js";
import {
  scanWaste,
  getScanHistory,
  getScanStats,
} from "../controllers/waste.controller.js";

const router = express.Router();

// All waste routes require authentication
router.post("/scan", authentication, scanWaste);
router.get("/history", authentication, getScanHistory);
router.get("/stats", authentication, getScanStats);

export default router;
