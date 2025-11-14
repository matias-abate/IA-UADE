export enum TipoElectrodomestico {
  HELADERA = 'HELADERA',
  LAVARROPAS = 'LAVARROPAS',
  MICROONDAS = 'MICROONDAS'
}

export enum EstadoCaso {
  EN_DIAGNOSTICO = 'EN_DIAGNOSTICO',
  RESUELTO_DIY = 'RESUELTO_DIY',
  REQUIERE_TECNICO = 'REQUIERE_TECNICO',
  CERRADO = 'CERRADO'
}

export enum Urgencia {
  BAJA = 'BAJA',
  MEDIA = 'MEDIA',
  ALTA = 'ALTA',
  CRITICA = 'CRITICA'
}

export interface Caso {
  id: number;
  clienteNombre: string;
  clienteTelefono: string;
  tipo: TipoElectrodomestico;
  marca: string;
  modelo: string;
  antiguedad: number;
  sintomaReportado: string;
  estado: EstadoCaso;
  fechaCreacion: string;
  respuestas?: Respuesta[];
}

export interface Respuesta {
  id: number;
  preguntaId: number;
  valor: string;
  timestamp: string;
}

export interface Pregunta {
  id: number;
  texto: string;
  tipo?: string;
  ayuda?: string;
  opciones?: string[] | null;
  critica?: boolean;
  imagenReferencia?: string | null;
}

export interface Diagnostico {
  casoId: number;
  causaProbable: string;
  certeza: number;
  componenteAfectado: string;
  requiereTecnico: boolean;
  urgencia: Urgencia;
  costoMinimo: number;
  costoMaximo: number;
  tiempoEstimado: number;
  probabilidadExitoDIY: number;
  scriptCliente: string;
}

export interface Hipotesis {
  nombre: string;
  probabilidad: number;
  nivel: string;
}

export interface Metricas {
  casosTotales: number;
  diyExitosos: number;
  tecnicoEnviados: number;
  tiempoPromedio: number;
}