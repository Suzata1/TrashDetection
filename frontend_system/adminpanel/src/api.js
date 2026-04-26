import axios from "axios";

const API = axios.create({
  baseURL: "http://localhost:4000/api",
});

// ===============================
// REQUEST INTERCEPTOR (AUTO TOKEN)
// ===============================
API.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// ===============================
// RESPONSE INTERCEPTOR (GLOBAL ERROR HANDLING)
// ===============================
API.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      console.log("Unauthorized → logging out user");

      localStorage.removeItem("token");
      window.location.href = "/login";
    }

    return Promise.reject(error);
  }
);

export default API;