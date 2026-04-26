import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();

// const MONGO_URL = process.env.MONGO_URL;
const connectDB = async () => {
  try {
    console.log(process.env.MONGO_URL);
    await mongoose.connect(process.env.MONGO_URL, { family: 4 })
    console.log("Mongo connected successfully");
  } catch (error) {
    console.log("Error in connecting to MongoDB", error);
    // process.exit(1);
  }
};

export default connectDB;
