# TrashDetection Admin Platform

The **TrashDetection Admin Platform** is a full-stack solution built to manage eco-friendly trash collection, recycling partnerships, locations, and user rewards via eSewa.

## Project Structure
- `/backend_system`: Node.js, Express, and MongoDB backend API.
- `/frontend_system/adminpanel`: React (Vite) admin dashboard built with TypeScript and Tailwind/Custom CSS.
- `/frontend_system/mobile_app`: Flutter mobile app.

## Features
1. **Light/White Theme Dashboard**: Modern, clean interface with eco-friendly emerald green accents.
2. **Dashboard Analytics**: View Total Users, Recycled Wastes, Carbon Emission Saved, and Rewards Earned.
3. **Users & Rewards Redemption**: Manage users, view credit balances, and process payouts using a simulated eSewa integration popup.
4. **Partners Management**: Full CRUD interface for recycling partners.
5. **Locations Management**: Full CRUD interface for trash collection/vendor locations.

## Quick Start

### 1. Backend Setup
```bash
cd backend_system
npm install
# Create a .env file based on environment variables (MONGO_URL, JWT_SECRET, PORT)
npm start
```
The backend runs on `http://localhost:4000`.

### 2. Frontend Admin Panel Setup
```bash
cd frontend_system/adminpanel
npm install
npm run dev
```
The frontend runs on `http://localhost:5173`.

## Architecture & Technologies
- **Frontend**: React 19, TypeScript, Vite, React Router, React Hot Toast, React Icons.
- **Backend**: Node.js, Express.js, Mongoose (MongoDB), JSON Web Tokens (JWT), Bcrypt.
- **Styling**: Vanilla CSS custom properties with localized responsive design.
