import mongoose from "mongoose";
import dotenv from "dotenv";
import userModel from "./models/user.model.js";

dotenv.config();

const dummyUsers = [
  {
    name: "Ram Sharma",
    email: "ram@example.com",
    phone: "9841000001",
    password: "password123", // Will be hashed below
    role: "user",
    credits: 500,
  },
  {
    name: "Sita Thapa",
    email: "sita@example.com",
    phone: "9841000002",
    password: "password123",
    role: "user",
    credits: 1250,
  },
  {
    name: "Hari Khadka",
    email: "hari@example.com",
    phone: "9841000003",
    password: "password123",
    role: "user",
    credits: 2400,
  },
];

const seedUsers = async () => {
  try {
    console.log("Connecting to MongoDB...");
    await mongoose.connect(process.env.MONGO_URL, { family: 4 });
    console.log("Connected.");

    // Remove old dummy users if any to avoid unique email errors
    await userModel.deleteMany({ email: { $in: dummyUsers.map(u => u.email) } });

    // Seed new users
    for (let u of dummyUsers) {
      // In a real scenario we hash the password, but for direct DB seed we can use a basic hash or bypass if only testing UI
      // Since it's a seed, we'll bypass hash for speed (they won't be able to login, but we just need them in the list)
      await userModel.create(u);
    }

    console.log("3 dummy users seeded successfully!");
    process.exit(0);
  } catch (err) {
    console.error("Error seeding:", err);
    process.exit(1);
  }
};

seedUsers();
