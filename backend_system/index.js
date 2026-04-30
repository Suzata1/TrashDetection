import express from "express";
import dotenv from "dotenv";
import connectDB from "./config/db.js";
import cors from "cors";

import userRoutes from "./routes/user.route.js";
import authRoutes from "./routes/auth.route.js";
import adminRoutes from "./routes/admin.route.js";
import partnerRoutes from "./routes/partner.route.js";
import locationRoutes from "./routes/location.route.js";
import wasteRoutes from "./routes/waste.route.js";

dotenv.config();
connectDB();

const app = express();
const PORT = process.env.PORT || 4000;

// ================= CORS =================
app.use(
  cors({
    origin: ["http://localhost:5173", "http://localhost:3000"], // React frontends
    credentials: true,
  })
);
// Also allow requests from mobile apps (no origin header)
app.use((req, res, next) => {
  if (!req.headers.origin) {
    res.header("Access-Control-Allow-Origin", "*");
  }
  next();
});

// ================= MIDDLEWARE =================
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ================= ROUTES =================
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/partners", partnerRoutes);
app.use("/api/locations", locationRoutes);
app.use("/api/waste", wasteRoutes);

// ================= TEST ROUTE =================
app.get("/", (req, res) => {
  res.send("TrashDetectionApp Backend is running 🚀");
});

// ================= SERVER =================
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});