import Jwt from "jsonwebtoken";
import dotenv from 'dotenv';

const authentication = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer")) {
      return res.status(401).json({
        message: "Token not found!",
        success: false,
      });
    }

    const token = authHeader.split(" ")[1];

    const decodeToken = Jwt.verify(token, process.env.JWT_SECRET);

    req.user = decodeToken;

    next();

  } catch (err) {
    res.status(401).json({
      message: "Unauthorized Access",
      success: false,
    });
  }
};

export default authentication;