// ...existing code...

// Alrededor de la línea 214, reemplazar el map sin validación por:
{preguntaActual.tipo !== 'SI_NO' && preguntaActual.opciones?.map((opcion: string, index: number) => (
  <button
    key={index}
    onClick={() => handleRespuesta(opcion)}
    className="w-full p-4 text-left border rounded hover:bg-gray-50"
  >
    {opcion}
  </button>
))}

// ...existing code...
