import cloudinary from "cloudinary";
import dotenv from 'dotenv';
const cloudinaryConfig = async () => {
  try {
    await cloudinary.config({
      cloud_name: process.env.CLOUDNAME,
      api_key: process.env.API_KEY,
      api_secret: process.env.API_SECRET,
    });
    console.log("Cloudinary Configured...");
  } catch (err) {
    console.log(err.message);
  }
};