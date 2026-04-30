import mongoose from "mongoose";

const wasteScanSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    wasteType: {
      type: String,
      enum: ["cardboard", "glass", "metal", "paper", "plastic", "trash"],
      required: true,
    },

    confidence: {
      type: Number,
      required: true,
    },

    creditsEarned: {
      type: Number,
      required: true,
    },

    co2Saved: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

export default mongoose.model("WasteScan", wasteScanSchema);
