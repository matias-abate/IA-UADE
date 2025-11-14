import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Home, CheckCircle, AlertTriangle, Info, User, Package } from 'lucide-react';
import { casoApi } from '../../services/api';
import { Caso } from '../../types';

export default function Result() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [caso, setCaso] = useState<Caso | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    cargarDatos();
  }, [id]);

  const cargarDatos = async () => {
    try {
      const casoRes = await casoApi.obtener(Number(id));
      setCaso(casoRes.data);
      
      // Si el caso ya está finalizado, obtener el último diagnóstico
      if (casoRes.data.estado !== 'EN_DIAGNOSTICO') {
        // Aquí deberías tener un endpoint que devuelva el diagnóstico guardado
        // Por ahora simulamos que viene en el caso
      }
    } catch (error) {
      console.error('Error al cargar datos:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="flex flex-col items-center gap-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="text-gray-600">Cargando resultados...</p>
        </div>
      </div>
    );
  }

  if (!caso) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center">
          <AlertTriangle className="w-12 h-12 text-red-600 mx-auto mb-3" />
          <h3 className="text-lg font-semibold text-red-800">Caso no encontrado</h3>
        </div>
      </div>
    );
  }

  const esRequiereTecnico = caso.estado === 'REQUIERE_TECNICO';
  const esResuelto = caso.estado === 'RESUELTO_DIY';

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header con estado */}
      <div className={`rounded-xl shadow-lg p-8 border-2 ${
        esRequiereTecnico 
          ? 'bg-gradient-to-br from-red-50 to-orange-50 border-red-200' 
          : esResuelto
          ? 'bg-gradient-to-br from-green-50 to-emerald-50 border-green-200'
          : 'bg-gradient-to-br from-yellow-50 to-amber-50 border-yellow-200'
      }`}>
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6">
          <div className="flex items-center gap-4">
            <div className={`p-4 rounded-full ${
              esRequiereTecnico 
                ? 'bg-red-100' 
                : esResuelto
                ? 'bg-green-100'
                : 'bg-yellow-100'
            }`}>
              {esRequiereTecnico ? (
                <AlertTriangle className="w-8 h-8 text-red-600" />
              ) : esResuelto ? (
                <CheckCircle className="w-8 h-8 text-green-600" />
              ) : (
                <Info className="w-8 h-8 text-yellow-600" />
              )}
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-800 mb-1">
                Resultado del Diagnóstico
              </h2>
              <p className="text-gray-600">Caso #{caso.id}</p>
            </div>
          </div>
          
          <span className={`px-6 py-3 rounded-xl font-semibold text-lg border-2 ${
            esRequiereTecnico 
              ? 'bg-red-100 text-red-800 border-red-300' 
              : esResuelto
              ? 'bg-green-100 text-green-800 border-green-300'
              : 'bg-yellow-100 text-yellow-800 border-yellow-300'
          }`}>
            {caso.estado.replace('_', ' ')}
          </span>
        </div>

        {esRequiereTecnico && (
          <div className="bg-red-100 border-l-4 border-red-600 p-6 rounded-lg">
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-6 h-6 text-red-600 mt-1 flex-shrink-0" />
              <div>
                <h4 className="font-semibold text-red-900 mb-2 text-lg">
                  Se Requiere Atención Técnica Especializada
                </h4>
                <p className="text-red-800 leading-relaxed">
                  Este caso requiere la intervención de un técnico calificado para garantizar 
                  una reparación segura y efectiva del equipo.
                </p>
              </div>
            </div>
          </div>
        )}

        {esResuelto && (
          <div className="bg-green-100 border-l-4 border-green-600 p-6 rounded-lg">
            <div className="flex items-start gap-3">
              <CheckCircle className="w-6 h-6 text-green-600 mt-1 flex-shrink-0" />
              <div>
                <h4 className="font-semibold text-green-900 mb-2 text-lg">
                  Diagnóstico Resuelto Exitosamente
                </h4>
                <p className="text-green-800 leading-relaxed">
                  El problema ha sido identificado y puede ser solucionado siguiendo 
                  las recomendaciones proporcionadas.
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Información del Caso */}
      <div className="bg-white rounded-xl shadow-lg p-8 border border-gray-100">
        <h3 className="text-xl font-bold text-gray-800 mb-6 flex items-center gap-2">
          <Info className="w-6 h-6 text-indigo-600" />
          Información del Caso
        </h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
            <User className="w-5 h-5 text-indigo-600 mt-1" />
            <div>
              <p className="text-sm text-gray-600 mb-1">Cliente</p>
              <p className="font-semibold text-gray-800">{caso.clienteNombre}</p>
              <p className="text-sm text-gray-600">{caso.clienteTelefono}</p>
            </div>
          </div>

          <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
            <Package className="w-5 h-5 text-purple-600 mt-1" />
            <div>
              <p className="text-sm text-gray-600 mb-1">Equipo</p>
              <p className="font-semibold text-gray-800">
                {caso.tipo} {caso.marca} {caso.modelo}
              </p>
              <p className="text-sm text-gray-600">Antigüedad: {caso.antiguedad} años</p>
            </div>
          </div>

          <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg md:col-span-2">
            <AlertTriangle className="w-5 h-5 text-yellow-600 mt-1" />
            <div className="flex-1">
              <p className="text-sm text-gray-600 mb-1">Síntoma Reportado</p>
              <p className="font-semibold text-gray-800">{caso.sintomaReportado}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Botón de acción */}
      <button
        onClick={() => navigate('/')}
        className="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-4 rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg hover:shadow-xl flex items-center justify-center gap-2 font-medium text-lg"
      >
        <Home className="w-5 h-5" />
        Volver al Dashboard
      </button>
    </div>
  );
}