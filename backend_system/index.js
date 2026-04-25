import express from "express";
import dotenv from "dotenv";
import connectDB from "./config/db.js";
import cors from "cors";

import userRoutes from "./routes/user.route.js";
import authRoutes from "./routes/auth.routes.js";

dotenv.config();
connectDB();

const app = express();
const PORT = process.env.PORT || 3000;

// ================= CORS =================
app.use(
  cors({
    origin: "http://localhost:5173", // React frontend
    credentials: true,
  })
);

// ================= MIDDLEWARE =================
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ================= ROUTES =================
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);

// ================= TEST ROUTE =================
app.get("/", (req, res) => {
  res.send("TrashDetectionApp Backend is running 🚀");
});

// ================= SERVER =================
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});