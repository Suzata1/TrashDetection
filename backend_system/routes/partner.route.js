import express from "express";
import {
  createPartner,
  getPartners,
  updatePartner,
  deletePartner,
} from "../controllers/partner.controller.js";

const router = express.Router();

router.post("/", createPartner);
router.get("/", getPartners);
router.put("/:id", updatePartner);
router.delete("/:id", deletePartner);

export default router;
