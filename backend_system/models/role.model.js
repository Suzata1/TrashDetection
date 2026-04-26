import mongoose from "mongoose";
const roleSchema = new mongoose.Schema({
  name: String, // e.g., "Admin", "User"
  permissions: [String], // e.g., ["DELETE", "UPDATE_USER"]
});


const roleModel = mongoose.model("Role", roleSchema);

export default roleModel