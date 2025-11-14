import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Sparkles, HelpCircle, Lightbulb, ArrowRight, CheckCircle, AlertTriangle } from 'lucide-react';
import { casoApi } from '../../services/api';
import { Caso, Pregunta, Hipotesis } from '../../types';

export default function DiagnosticWizard() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [caso, setCaso] = useState<Caso | null>(null);
  const [preguntaActual, setPreguntaActual] = useState<Pregunta | null>(null);
  const [hipotesis, setHipotesis] = useState<Hipotesis[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [respuestaSeleccionada, setRespuestaSeleccionada] = useState<string>('');

  useEffect(() => {
    cargarDatos();
  }, [id]);

  const cargarDatos = async () => {
    try {
      setError(null);
      console.log('Cargando datos para caso:', id);

      // Primero obtener el caso
      const casoRes = await casoApi.obtener(Number(id));
      console.log('Caso obtenido:', casoRes.data);
      setCaso(casoRes.data);

      // Luego obtener la pregunta (esto inicializa las hipótesis en el backend)
      try {
        const preguntaRes = await casoApi.getSiguientePregunta(Number(id));
        console.log('Pregunta obtenida:', preguntaRes.data);
        setPreguntaActual(preguntaRes.data);

        // Ahora sí obtener las hipótesis (que ya fueron creadas)
        try {
          const hipotesisRes = await casoApi.getHipotesis(Number(id));
          console.log('Hipótesis obtenidas:', hipotesisRes.data);
          setHipotesis(hipotesisRes.data || []);
        } catch (hipErr) {
          console.log('No se pudieron cargar hipótesis:', hipErr);
          setHipotesis([]);
        }
      } catch (err: any) {
        console.error('Error al cargar pregunta:', err);
        // Si falla obtener la pregunta, no es fatal, podemos seguir
        if (err.response?.status === 404 || err.response?.status === 204) {
          console.log('No hay pregunta disponible todavía');
          setPreguntaActual(null);
          setHipotesis([]);
        } else {
          throw err;
        }
      }
    } catch (error: any) {
      console.error('Error al cargar datos:', error);
      setError(error.response?.data?.message || 'Error al cargar el diagnóstico. Por favor intente nuevamente.');
    } finally {
      setLoading(false);
    }
  };

  const responder = async () => {
    if (!respuestaSeleccionada || !preguntaActual) return;

    try {
      await casoApi.responder(Number(id), {
        preguntaId: preguntaActual.id,
        valor: respuestaSeleccionada
      });

      // Cargar siguiente pregunta
      const siguienteRes = await casoApi.getSiguientePregunta(Number(id));
      const hipotesisRes = await casoApi.getHipotesis(Number(id));
      
      if (siguienteRes.data) {
        setPreguntaActual(siguienteRes.data);
        setHipotesis(hipotesisRes.data);
        setRespuestaSeleccionada('');
      } else {
        // No hay más preguntas, finalizar diagnóstico
        await finalizarDiagnostico();
      }
    } catch (error) {
      console.error('Error al responder:', error);
    }
  };

  const finalizarDiagnostico = async () => {
    try {
      await casoApi.finalizar(Number(id));
      navigate(`/resultado/${id}`);
    } catch (error) {
      console.error('Error al finalizar:', error);
    }
  };

  const getProbabilidadColor = (probabilidad: number) => {
    if (probabilidad >= 70) return 'text-red-600 bg-red-100';
    if (probabilidad >= 40) return 'text-yellow-600 bg-yellow-100';
    return 'text-green-600 bg-green-100';
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="flex flex-col items-center gap-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="text-gray-600">Cargando diagnóstico...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-4xl mx-auto">
        <button
          onClick={() => navigate('/')}
          className="flex items-center gap-2 text-gray-600 hover:text-indigo-600 transition-colors mb-4"
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Volver al Dashboard</span>
        </button>
        <div className="bg-red-50 border border-red-200 rounded-xl p-8 text-center">
          <div className="bg-red-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
            <AlertTriangle className="w-8 h-8 text-red-600" />
          </div>
          <h3 className="text-xl font-semibold text-red-900 mb-2">
            Error al Cargar el Diagnóstico
          </h3>
          <p className="text-red-800 mb-6">{error}</p>
          <div className="flex gap-3 justify-center">
            <button
              onClick={() => navigate('/')}
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-all"
            >
              Volver al Dashboard
            </button>
            <button
              onClick={() => {
                setLoading(true);
                cargarDatos();
              }}
              className="px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-all"
            >
              Reintentar
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (!caso || !preguntaActual) {
    return (
      <div className="max-w-4xl mx-auto">
        <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-8 text-center">
          <CheckCircle className="w-16 h-16 text-yellow-600 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-yellow-900 mb-2">
            Diagnóstico Completo
          </h3>
          <p className="text-yellow-800 mb-6">
            Se han respondido todas las preguntas necesarias
          </p>
          <button
            onClick={finalizarDiagnostico}
            className="bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-8 py-3 rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg inline-flex items-center gap-2"
          >
            <Sparkles className="w-5 h-5" />
            Ver Resultado Final
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <button
        onClick={() => navigate('/')}
        className="flex items-center gap-2 text-gray-600 hover:text-indigo-600 transition-colors"
      >
        <ArrowLeft className="w-5 h-5" />
        <span>Volver al Dashboard</span>
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Pregunta Principal */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-xl shadow-lg p-8 border border-indigo-100">
            <div className="flex items-center gap-3 mb-6">
              <div className="bg-gradient-to-br from-indigo-600 to-purple-600 p-3 rounded-xl">
                <HelpCircle className="w-6 h-6 text-white" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Pregunta de Diagnóstico</p>
                <h2 className="text-2xl font-bold text-gray-800">{preguntaActual.texto}</h2>
              </div>
            </div>

            {preguntaActual.ayuda && (
              <div className="bg-blue-50 border-l-4 border-blue-400 p-4 mb-6 rounded-r-lg">
                <div className="flex items-start gap-2">
                  <Lightbulb className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
                  <p className="text-blue-800 text-sm">{preguntaActual.ayuda}</p>
                </div>
              </div>
            )}

            <div className="space-y-3">
              {preguntaActual.opciones && preguntaActual.opciones.map((opcion) => (
                <label
                  key={opcion}
                  className={`flex items-center p-4 border-2 rounded-xl cursor-pointer transition-all ${
                    respuestaSeleccionada === opcion
                      ? 'border-indigo-600 bg-indigo-50'
                      : 'border-gray-200 hover:border-indigo-300 hover:bg-gray-50'
                  }`}
                >
                  <input
                    type="radio"
                    name="respuesta"
                    value={opcion}
                    checked={respuestaSeleccionada === opcion}
                    onChange={(e) => setRespuestaSeleccionada(e.target.value)}
                    className="w-5 h-5 text-indigo-600"
                  />
                  <span className="ml-3 font-medium text-gray-800 capitalize">
                    {opcion.replace('_', ' ')}
                  </span>
                </label>
              ))}

              {/* Opciones SI/NO cuando no hay opciones específicas */}
              {!preguntaActual.opciones && preguntaActual.tipo === 'SI_NO' && (
                <>
                  <label
                    className={`flex items-center p-4 border-2 rounded-xl cursor-pointer transition-all ${
                      respuestaSeleccionada === 'true'
                        ? 'border-indigo-600 bg-indigo-50'
                        : 'border-gray-200 hover:border-indigo-300 hover:bg-gray-50'
                    }`}
                  >
                    <input
                      type="radio"
                      name="respuesta"
                      value="true"
                      checked={respuestaSeleccionada === 'true'}
                      onChange={(e) => setRespuestaSeleccionada(e.target.value)}
                      className="w-5 h-5 text-indigo-600"
                    />
                    <span className="ml-3 font-medium text-gray-800">Sí</span>
                  </label>
                  <label
                    className={`flex items-center p-4 border-2 rounded-xl cursor-pointer transition-all ${
                      respuestaSeleccionada === 'false'
                        ? 'border-indigo-600 bg-indigo-50'
                        : 'border-gray-200 hover:border-indigo-300 hover:bg-gray-50'
                    }`}
                  >
                    <input
                      type="radio"
                      name="respuesta"
                      value="false"
                      checked={respuestaSeleccionada === 'false'}
                      onChange={(e) => setRespuestaSeleccionada(e.target.value)}
                      className="w-5 h-5 text-indigo-600"
                    />
                    <span className="ml-3 font-medium text-gray-800">No</span>
                  </label>
                </>
              )}
            </div>

            <button
              onClick={responder}
              disabled={!respuestaSeleccionada}
              className="w-full mt-6 bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-4 rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 font-medium text-lg"
            >
              Siguiente Pregunta
              <ArrowRight className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Panel Lateral - Hipótesis */}
        <div className="space-y-6">
          {/* Información del Caso */}
          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
            <h3 className="font-semibold text-gray-800 mb-4">Información del Caso</h3>
            <div className="space-y-3 text-sm">
              <div>
                <p className="text-gray-600">Cliente</p>
                <p className="font-medium text-gray-800">{caso.clienteNombre}</p>
              </div>
              <div>
                <p className="text-gray-600">Equipo</p>
                <p className="font-medium text-gray-800">
                  {caso.tipo} {caso.marca}
                </p>
              </div>
              <div>
                <p className="text-gray-600">Síntoma</p>
                <p className="font-medium text-gray-800">{caso.sintomaReportado}</p>
              </div>
            </div>
          </div>

          {/* Hipótesis Actuales */}
          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
            <div className="flex items-center gap-2 mb-4">
              <Sparkles className="w-5 h-5 text-indigo-600" />
              <h3 className="font-semibold text-gray-800">Hipótesis Actuales</h3>
            </div>
            
            {hipotesis.length > 0 ? (
              <div className="space-y-3">
                {hipotesis.map((hip, index) => (
                  <div key={index} className="p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <p className="font-medium text-gray-800 text-sm">{hip.nombre}</p>
                      <span className={`px-2 py-1 rounded-full text-xs font-semibold ${getProbabilidadColor(hip.probabilidad)}`}>
                        {hip.probabilidad}%
                      </span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-gradient-to-r from-indigo-600 to-purple-600 h-2 rounded-full transition-all"
                        style={{ width: `${hip.probabilidad}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-500 text-sm">
                Las hipótesis aparecerán a medida que respondas las preguntas
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}