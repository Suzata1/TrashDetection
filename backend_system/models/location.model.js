import mongoose from "mongoose";

const locationSchema = new mongoose.Schema(
  {
    vendorName: {
      type: String,
      required: true,
    },
    vendorAddress: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ["Active", "Inactive"],
      default: "Active",
    },
  },
  { timestamps: true }
);

export default mongoose.model("Location", locationSchema);
