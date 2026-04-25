import multer from 'multer';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import cloudinary from '../config/cloudinary.js';

const storage = new CloudinaryStorage({
      cloudinary: cloudinary,
   params: {
    folder: "Images",
    allowed_formats: ["jpg", "png", "jpeg", "webp"],
    resource_type: "auto",
    overwrite: true,
  },
});

const upload = multer({ 
    storage: storage, 
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB

}
});


export default upload;