import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Clock, CheckCircle, AlertTriangle, TrendingUp, Users, Refrigerator } from 'lucide-react';
import { casoApi, metricasApi, CasoCreateDTO } from '../../services/api';
import NuevoCasoModal from './NuevoCasoModal';
import { Caso, Metricas } from '../../types';

export default function Dashboard() {
  const [casos, setCasos] = useState<Caso[]>([]);
  const [loading, setLoading] = useState(true);
  const [metricas, setMetricas] = useState<Metricas | null>(null);
  const [modalOpen, setModalOpen] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    cargarDatos();
  }, []);

  const cargarDatos = async () => {
    try {
      const [casosRes, metricasRes] = await Promise.all([
        casoApi.listar(),
        metricasApi.obtener()
      ]);
      // Ordenar casos por fecha de creación descendente (más recientes primero)
      const casosOrdenados = casosRes.data.sort((a: Caso, b: Caso) =>
        new Date(b.fechaCreacion).getTime() - new Date(a.fechaCreacion).getTime()
      );
      setCasos(casosOrdenados);
      setMetricas(metricasRes.data);
    } catch (error) {
      console.error('Error al cargar datos:', error);
    } finally {
      setLoading(false);
    }
  };

  const crearNuevoCaso = async (data: CasoCreateDTO) => {
    try {
      const response = await casoApi.crear(data);
      setModalOpen(false);
      navigate(`/diagnostico/${response.data.id}`);
    } catch (error) {
      console.error('Error al crear caso:', error);
      alert('Error al crear el caso. Por favor intente nuevamente.');
    }
  };

  const getEstadoColor = (estado: string) => {
    switch (estado) {
      case 'EN_DIAGNOSTICO':
        return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'REQUIERE_TECNICO':
        return 'bg-red-100 text-red-800 border-red-200';
      case 'RESUELTO_DIY':
        return 'bg-green-100 text-green-800 border-green-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getEstadoIcon = (estado: string) => {
    switch (estado) {
      case 'EN_DIAGNOSTICO':
        return <Clock className="w-4 h-4" />;
      case 'REQUIERE_TECNICO':
        return <AlertTriangle className="w-4 h-4" />;
      case 'RESUELTO_DIY':
        return <CheckCircle className="w-4 h-4" />;
      default:
        return null;
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="flex flex-col items-center gap-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="text-gray-600">Cargando datos...</p>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Métricas */}
        {metricas && (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-white rounded-xl shadow-md p-6 border border-indigo-100 hover:shadow-lg transition-all">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Casos Totales</p>
                  <p className="text-3xl font-bold text-indigo-600">{metricas.casosTotales}</p>
                </div>
                <div className="bg-indigo-100 p-3 rounded-lg">
                  <Users className="w-6 h-6 text-indigo-600" />
                </div>
              </div>
            </div>

            <div className="bg-white rounded-xl shadow-md p-6 border border-green-100 hover:shadow-lg transition-all">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Resueltos DIY</p>
                  <p className="text-3xl font-bold text-green-600">{metricas.diyExitosos}</p>
                </div>
                <div className="bg-green-100 p-3 rounded-lg">
                  <CheckCircle className="w-6 h-6 text-green-600" />
                </div>
              </div>
            </div>

            <div className="bg-white rounded-xl shadow-md p-6 border border-red-100 hover:shadow-lg transition-all">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Técnico Requerido</p>
                  <p className="text-3xl font-bold text-red-600">{metricas.tecnicoEnviados}</p>
                </div>
                <div className="bg-red-100 p-3 rounded-lg">
                  <AlertTriangle className="w-6 h-6 text-red-600" />
                </div>
              </div>
            </div>

            <div className="bg-white rounded-xl shadow-md p-6 border border-purple-100 hover:shadow-lg transition-all">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Tiempo Promedio</p>
                  <p className="text-3xl font-bold text-purple-600">{metricas.tiempoPromedio}m</p>
                </div>
                <div className="bg-purple-100 p-3 rounded-lg">
                  <TrendingUp className="w-6 h-6 text-purple-600" />
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Header con botón */}
        <div className="bg-white rounded-xl shadow-md p-6 border border-gray-100">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
            <div>
              <h2 className="text-3xl font-bold text-gray-800 mb-2">Casos de Diagnóstico</h2>
              <p className="text-gray-600">Gestiona y diagnostica problemas de electrodomésticos</p>
            </div>
            <button
              onClick={() => setModalOpen(true)}
              className="bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-3 rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg hover:shadow-xl flex items-center gap-2 font-medium"
            >
              <Plus className="w-5 h-5" />
              Nuevo Caso
            </button>
          </div>
        </div>

        {/* Lista de casos */}
        {casos.length === 0 ? (
          <div className="bg-white rounded-xl shadow-md p-12 text-center border border-gray-100">
            <div className="max-w-md mx-auto">
              <div className="bg-indigo-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4">
                <Refrigerator className="w-10 h-10 text-indigo-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-800 mb-2">No hay casos registrados</h3>
              <p className="text-gray-600 mb-6">Comienza creando tu primer caso de diagnóstico</p>
              <button
                onClick={() => setModalOpen(true)}
                className="bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-6 py-3 rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all inline-flex items-center gap-2"
              >
                <Plus className="w-5 h-5" />
                Crear Primer Caso
              </button>
            </div>
          </div>
        ) : (
          <div className="grid gap-4">
            {casos.map((caso) => (
              <div
                key={caso.id}
                className="bg-white rounded-xl shadow-md hover:shadow-xl transition-all p-6 cursor-pointer border border-gray-100 hover:border-indigo-200"
                onClick={() => navigate(`/diagnostico/${caso.id}`)}
              >
                <div className="flex flex-col md:flex-row justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-start gap-3 mb-3">
                      <div className="bg-indigo-100 p-2 rounded-lg">
                        <Refrigerator className="w-5 h-5 text-indigo-600" />
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold text-gray-800 mb-1">
                          {caso.clienteNombre}
                        </h3>
                        <p className="text-sm text-gray-500">
                          {new Date(caso.fechaCreacion).toLocaleDateString('es-ES', {
                            day: '2-digit',
                            month: 'long',
                            year: 'numeric'
                          })}
                        </p>
                      </div>
                    </div>
                    
                    <div className="space-y-2 ml-11">
                      <p className="text-gray-700">
                        <span className="font-medium text-gray-800">Equipo:</span>{' '}
                        {caso.tipo} {caso.marca} {caso.modelo}
                      </p>
                      <p className="text-gray-700">
                        <span className="font-medium text-gray-800">Síntoma:</span>{' '}
                        {caso.sintomaReportado}
                      </p>
                      <p className="text-sm text-gray-500">
                        Antigüedad: {caso.antiguedad} años
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <span className={`px-4 py-2 rounded-xl text-sm font-medium border flex items-center gap-2 ${getEstadoColor(caso.estado)}`}>
                      {getEstadoIcon(caso.estado)}
                      {caso.estado.replace('_', ' ')}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <NuevoCasoModal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        onSubmit={crearNuevoCaso}
      />
    </>
  );
}