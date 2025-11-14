import axios from 'axios';

const API_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export enum TipoElectrodomestico {
  HELADERA = 'HELADERA',
  LAVARROPAS = 'LAVARROPAS',
  MICROONDAS = 'MICROONDAS'
}

export interface CasoCreateDTO {
  clienteNombre: string;
  clienteTelefono: string;
  tipo: TipoElectrodomestico;
  marca: string;
  modelo: string;
  antiguedad: number;
  sintomaReportado: string;
}

export interface RespuestaDTO {
  preguntaId: number;
  valor: string;
}

export const casoApi = {
  crear: (data: CasoCreateDTO) => api.post('/casos', data),
  obtener: (id: number) => api.get(`/casos/${id}`),
  listar: () => api.get('/casos'),
  getSiguientePregunta: (id: number) => api.get(`/casos/${id}/siguiente-pregunta`),
  responder: (id: number, data: RespuestaDTO) => api.post(`/casos/${id}/responder`, data),
  getHipotesis: (id: number) => api.get(`/casos/${id}/hipotesis`),
  finalizar: (id: number) => api.post(`/casos/${id}/finalizar`),
};

export const metricasApi = {
  obtener: () => api.get('/metricas'),
};

export default api;