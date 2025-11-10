import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for adding auth tokens if needed
api.interceptors.request.use(
  (config) => {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    if (user.token) {
      config.headers.Authorization = `Bearer ${user.token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for handling errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Log error for debugging
    console.error('API Error:', {
      url: error.config?.url,
      method: error.config?.method,
      status: error.response?.status,
      data: error.response?.data,
      message: error.message,
    });

    if (error.response?.status === 401) {
      // Handle unauthorized - could redirect to login
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    
    // Handle network errors
    if (!error.response) {
      console.error('Network error - is the backend running?');
      error.message = 'Cannot connect to backend. Please ensure the backend server is running on http://localhost:8080';
    }
    
    return Promise.reject(error);
  }
);

export const rewardAPI = {
  create: (data) => api.post('/reward', data),
  getTodayStocks: (userId) => api.get(`/today-stocks/${userId}`),
};

export const portfolioAPI = {
  getPortfolio: (userId) => api.get(`/portfolio/${userId}`),
  getStats: (userId) => api.get(`/stats/${userId}`),
  getHistoricalINR: (userId) => api.get(`/historical-inr/${userId}`),
};

export default api;

