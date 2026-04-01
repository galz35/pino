import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:3010/api',
});

// CACHE EN MEMORIA PARA MÁXIMA VELOCIDAD
const memoryCache = new Map<string, { data: any; timestamp: number }>();
const CACHE_TTL = 5000; // 5 segundos para invalidación rápida

// Interceptor para incluir el token JWT en cada petición
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  // Si la petición es un GET y está en caché, la interceptamos después
  return config;
});

// Interceptor para manejar errores globales y CACHÉ
apiClient.interceptors.response.use(
  (response) => {
    // Solo cacheamos peticiones GET exitosas
    if (response.config.method === 'get') {
      const cacheKey = `${response.config.url}${JSON.stringify(response.config.params || {})}`;
      memoryCache.set(cacheKey, {
        data: response.data,
        timestamp: Date.now()
      });
    }
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.clear();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Wrapper para inyectar caché antes de la petición real
const originalGet = apiClient.get;
apiClient.get = async function (url, config) {
  const cacheKey = `${url}${JSON.stringify(config?.params || {})}`;
  const cached = memoryCache.get(cacheKey);
  
  if (cached && (Date.now() - cached.timestamp < CACHE_TTL)) {
    return { data: cached.data } as any;
  }
  
  return originalGet.call(this, url, config);
};

export default apiClient;
