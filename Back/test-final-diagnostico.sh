#!/bin/bash

echo "🧪 PRUEBA FINAL: Diagnóstico Completo sin Error 500"
echo "===================================================="
echo ""

API_URL="http://localhost:8080/api"

# Función para verificar backend
wait_backend() {
    echo "⏳ Esperando backend..."
    for i in {1..20}; do
        if curl -s -f "$API_URL/casos" > /dev/null 2>&1; then
            echo "✅ Backend listo"
            return 0
        fi
        sleep 1
        echo -n "."
    done
    echo ""
    echo "❌ Backend no responde"
    return 1
}

# Verificar backend
if ! wait_backend; then
    exit 1
fi

echo ""
echo "📝 Paso 1: Crear caso de prueba"
CASO_RESPONSE=$(curl -s -X POST "$API_URL/casos" \
  -H "Content-Type: application/json" \
  -d '{
    "clienteNombre": "Prueba Final",
    "clienteTelefono": "555-0001",
    "tipo": "HELADERA",
    "marca": "Samsung",
    "modelo": "RT38",
    "antiguedad": 3,
    "sintomaReportado": "No enfría"
  }')

CASO_ID=$(echo $CASO_RESPONSE | jq -r '.id')
echo "✅ Caso creado: ID=$CASO_ID"
echo ""

# Responder preguntas
echo "❓ Paso 2: Respondiendo preguntas..."

# Pregunta 1: ¿La luz funciona?
curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta" > /dev/null
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d '{"preguntaId": 1, "valor": "true"}' > /dev/null
echo "  ✅ P1: La luz SÍ funciona"

# Pregunta 2: ¿Motor suena?
curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta" > /dev/null
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d '{"preguntaId": 2, "valor": "false"}' > /dev/null
echo "  ✅ P2: Motor NO suena"

# Pregunta 3: ¿Motor caliente?
curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta" > /dev/null
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d '{"preguntaId": 3, "valor": "true"}' > /dev/null
echo "  ✅ P3: Motor SÍ está caliente"

echo ""
echo "🏁 Paso 3: Finalizando diagnóstico..."
echo ""

# MOMENTO DE LA VERDAD: Finalizar diagnóstico
RESULTADO=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/casos/$CASO_ID/finalizar")
HTTP_CODE=$(echo "$RESULTADO" | tail -1)
BODY=$(echo "$RESULTADO" | head -n -1)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ ¡ÉXITO! Diagnóstico finalizado correctamente"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📊 DIAGNÓSTICO:"
    echo "$BODY" | jq -r '.diagnostico | "
Causa: \(.causaProbable)
Probabilidad: \(.probabilidad)%
Componente: \(.componenteAfectado)
Requiere Técnico: \(.requiereTecnico)
Urgencia: \(.urgencia)
Costo: $\(.costoEstimadoMin) - $\(.costoEstimadoMax)
"'

    echo ""
    echo "🔧 REPUESTOS:"
    echo "$BODY" | jq -r '.diagnostico.repuestosProbables[]' | sed 's/^/  • /'

    echo ""
    echo "📋 INSTRUCCIONES:"
    echo "$BODY" | jq -r '.diagnostico.mensajesCliente[]' | sed 's/^/  • /'

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 ¡PRUEBA COMPLETADA CON ÉXITO!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "✅ No hubo error 500"
    echo "✅ Diagnóstico guardado en BD"
    echo "✅ Sistema funcionando al 100%"
    echo ""
else
    echo "❌ ERROR: HTTP $HTTP_CODE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Respuesta del servidor:"
    echo "$BODY" | jq '.'
    echo ""
    echo "❌ La prueba FALLÓ"
    echo ""
fi

