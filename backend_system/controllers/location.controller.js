import locationModel from "../models/location.model.js";

// ================= CREATE LOCATION =================
export const createLocation = async (req, res) => {
  try {
    const { vendorName, vendorAddress, status } = req.body;

    const location = await locationModel.create({
      vendorName,
      vendorAddress,
      status: status || "Active",
    });

    return res.status(201).json({
      message: "Location created successfully",
      location,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= GET ALL LOCATIONS =================
export const getLocations = async (req, res) => {
  try {
    const locations = await locationModel.find().sort({ createdAt: -1 });

    return res.json({
      message: "Locations fetched",
      locations,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= UPDATE LOCATION =================
export const updateLocation = async (req, res) => {
  try {
    const { id } = req.params;
    const { vendorName, vendorAddress, status } = req.body;

    const location = await locationModel.findByIdAndUpdate(
      id,
      { vendorName, vendorAddress, status },
      { new: true }
    );

    if (!location) {
      return res.status(404).json({ message: "Location not found" });
    }

    return res.json({
      message: "Location updated successfully",
      location,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= DELETE LOCATION =================
export const deleteLocation = async (req, res) => {
  try {
    const location = await locationModel.findByIdAndDelete(req.params.id);
    
    if (!location) {
      return res.status(404).json({ message: "Location not found" });
    }

    return res.json({
      message: "Location deleted successfully",
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};
