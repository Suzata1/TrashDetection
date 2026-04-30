import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
    },

    phone: {
      type: String,
      default: "",
    },

    credits: {
      type: Number,
      default: 0,
    },

    password: {
      type: String,
      required: true,
      select: false,
    },

    role: {
      type: String,
      enum: ["user", "admin"],
      default: "user",
    },

    profilePicture: {
      type: String,
      default: "",
    },

    passwordResetToken: String,
    passwordResetExpires: Date,
  },
 
  { timestamps: true }
);

export default mongoose.model("User", userSchema);