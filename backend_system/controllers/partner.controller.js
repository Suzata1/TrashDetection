import partnerModel from "../models/partner.model.js";

// ================= CREATE PARTNER =================
export const createPartner = async (req, res) => {
  try {
    const { name, email, phone } = req.body;

    const exists = await partnerModel.findOne({ email });
    if (exists) {
      return res.status(400).json({ message: "Partner with this email already exists" });
    }

    const partner = await partnerModel.create({
      name,
      email,
      phone,
    });

    return res.status(201).json({
      message: "Partner created successfully",
      partner,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= GET ALL PARTNERS =================
export const getPartners = async (req, res) => {
  try {
    const partners = await partnerModel.find().sort({ createdAt: -1 });

    return res.json({
      message: "Partners fetched",
      partners,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= UPDATE PARTNER =================
export const updatePartner = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, phone } = req.body;

    // Check email uniqueness if email is being updated
    if (email) {
      const existing = await partnerModel.findOne({ email, _id: { $ne: id } });
      if (existing) {
        return res.status(400).json({ message: "Another partner is using this email" });
      }
    }

    const partner = await partnerModel.findByIdAndUpdate(
      id,
      { name, email, phone },
      { new: true }
    );

    if (!partner) {
      return res.status(404).json({ message: "Partner not found" });
    }

    return res.json({
      message: "Partner updated successfully",
      partner,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// ================= DELETE PARTNER =================
export const deletePartner = async (req, res) => {
  try {
    const partner = await partnerModel.findByIdAndDelete(req.params.id);
    
    if (!partner) {
      return res.status(404).json({ message: "Partner not found" });
    }

    return res.json({
      message: "Partner deleted successfully",
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};
