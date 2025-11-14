import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { ArrowLeft, Sparkles, Phone, Calendar, Package, AlertCircle } from 'lucide-react';

const API_URL = 'http://localhost:8080/api';

export default function Diagnostic() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [caso, setCaso] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    cargarCaso();
  }, [id]);

  const cargarCaso = async () => {
    try {
      const response = await axios.get(`${API_URL}/casos/${id}`);
      setCaso(response.data);
    } catch (error) {
      console.error('Error al cargar caso:', error);
    } finally {
      setLoading(false);
    }
  };

  const diagnosticar = async () => {
    try {
      await axios.post(`${API_URL}/casos/${id}/diagnosticar`);
      navigate(`/resultado/${id}`);
    } catch (error) {
      console.error('Error al diagnosticar:', error);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="flex flex-col items-center gap-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="text-gray-600">Cargando caso...</p>
        </div>
      </div>
    );
  }

  if (!caso) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center">
          <AlertCircle className="w-12 h-12 text-red-600 mx-auto mb-3" />
          <h3 className="text-lg font-semibold text-red-800 mb-2">Caso no encontrado</h3>
          <button
            onClick={() => navigate('/')}
            className="mt-4 text-indigo-600 hover:text-indigo-700 font-medium"
          >
            Volver al dashboard
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <button
        onClick={() => navigate('/')}
        className="flex items-center gap-2 text-gray-600 hover:text-indigo-600 transition-colors mb-4"
      >
        <ArrowLeft className="w-5 h-5" />
        <span>Volver al Dashboard</span>
      </button>

      {/* Información del Caso */}
      <div className="bg-white rounded-xl shadow-lg p-8 border border-indigo-100">
        <div className="flex items-center gap-3 mb-6">
          <div className="bg-gradient-to-br from-indigo-600 to-purple-600 p-3 rounded-xl">
            <Package className="w-6 h-6 text-white" />
          </div>
          <h2 className="text-2xl font-bold text-gray-800">Información del Caso</h2>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-4">
            <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
              <div className="bg-indigo-100 p-2 rounded-lg mt-1">
                <Phone className="w-5 h-5 text-indigo-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Cliente</p>
                <p className="font-semibold text-gray-800">{caso.clienteNombre}</p>
                <p className="text-sm text-gray-600">{caso.clienteTelefono}</p>
              </div>
            </div>

            <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
              <div className="bg-purple-100 p-2 rounded-lg mt-1">
                <Package className="w-5 h-5 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Equipo</p>
                <p className="font-semibold text-gray-800">
                  {caso.tipo} {caso.marca}
                </p>
                <p className="text-sm text-gray-600">Modelo: {caso.modelo}</p>
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <div className="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
              <div className="bg-blue-100 p-2 rounded-lg mt-1">
                <Calendar className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Antigüedad</p>
                <p className="font-semibold text-gray-800">{caso.antiguedad} años</p>
              </div>
            </div>

            <div className="flex items-start gap-3 p-4 bg-yellow-50 rounded-lg border border-yellow-200">
              <div className="bg-yellow-100 p-2 rounded-lg mt-1">
                <AlertCircle className="w-5 h-5 text-yellow-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Síntoma Reportado</p>
                <p className="font-semibold text-gray-800">{caso.sintomaReportado}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Diagnóstico */}
      <div className="bg-gradient-to-br from-indigo-50 to-purple-50 rounded-xl shadow-lg p-8 border border-indigo-200">
        <div className="text-center max-w-2xl mx-auto">
          <div className="bg-white w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg">
            <Sparkles className="w-10 h-10 text-indigo-600" />
          </div>
          
          <h3 className="text-2xl font-bold text-gray-800 mb-3">
            Diagnóstico Inteligente
          </h3>
          <p className="text-gray-600 mb-8">
            Nuestro sistema experto analizará toda la información del caso para generar 
            un diagnóstico preciso y recomendaciones específicas.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button
              onClick={diagnosticar}
              className="bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-8 py-4 rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg hover:shadow-xl flex items-center justify-center gap-2 font-medium text-lg"
            >
              <Sparkles className="w-5 h-5" />
              Generar Diagnóstico
            </button>
            <button
              onClick={() => navigate('/')}
              className="bg-white text-gray-700 px-8 py-4 rounded-xl hover:bg-gray-50 transition-all shadow-md hover:shadow-lg border border-gray-200 font-medium"
            >
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}