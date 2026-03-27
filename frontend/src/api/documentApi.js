import axios from 'axios';

// API base URL — always use relative path so nginx proxies /api/* to backend.
// VITE_API_URL is only needed for local dev without Vite proxy.
// For Docker/production: VITE_API_URL should be empty → relative URL works via nginx.
const API_BASE = (import.meta.env.VITE_API_URL || '') + '/api/documents';

// Axios instance with default config
const api = axios.create({
  baseURL: API_BASE,
  timeout: 30000,
  headers: { 'Content-Type': 'application/json' },
});

// Response interceptor: handle common errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      console.error('Unauthorized — check credentials')
    }
    if (error.response?.status === 403) {
      console.error('Forbidden — check permissions')
    }
    if (!error.response) {
      console.error('Network error — backend may be unreachable')
    }
    return Promise.reject(error)
  }
)

export { api }

export const documentApi = {
  // Upload document
  upload: async (name, file) => {
    const formData = new FormData();
    formData.append('name', name);
    formData.append('file', file);
    const response = await api.post('', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  // Get all documents
  getAll: async () => {
    const response = await api.get('');
    return response.data;
  },

  // Download document
  download: async (id, fileName) => {
    const response = await api.get(`/${id}`, {
      responseType: 'blob',
    });
    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', fileName);
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(url);
  },

  // Update document
  update: async (id, name, file) => {
    const formData = new FormData();
    if (name) formData.append('name', name);
    if (file) formData.append('file', file);
    const response = await api.put(`/${id}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  // Delete document
  delete: async (id) => {
    await api.delete(`/${id}`);
  },
};
