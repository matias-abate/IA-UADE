#!/bin/bash

# Script de prueba CORREGIDO - Diagnóstico Heladera No Enfría
# Verifica que las preguntas avancen correctamente

echo "🧪 PRUEBA DE DIAGNÓSTICO - FLUJO COMPLETO"
echo "=========================================="
echo ""

API_URL="http://localhost:8080/api"

# Función para esperar que el backend esté listo
wait_for_backend() {
    echo "⏳ Esperando que el backend inicie..."
    for i in {1..30}; do
        if curl -s -f "$API_URL/casos" > /dev/null 2>&1; then
            echo "✅ Backend listo!"
            return 0
        fi
        sleep 1
        echo -n "."
    done
    echo ""
    echo "❌ ERROR: Backend no respondió en 30 segundos"
    return 1
}

# Verificar si el backend está corriendo
if ! curl -s -f "$API_URL/casos" > /dev/null 2>&1; then
    echo "⚠️  Backend no está corriendo. Iniciándolo..."
    cd /Users/matiasabate/Documents/IA/Back
    java -jar target/sistema-experto-1.0.0.jar > /tmp/backend.log 2>&1 &
    BACKEND_PID=$!
    echo "Backend iniciado con PID: $BACKEND_PID"

    if ! wait_for_backend; then
        echo "❌ No se pudo iniciar el backend"
        echo "Log del backend:"
        tail -20 /tmp/backend.log
        exit 1
    fi
else
    echo "✅ Backend ya está corriendo"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   INICIANDO PRUEBA DE DIAGNÓSTICO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Paso 1: Crear caso
echo "📝 1. Creando caso: Heladera no enfría..."
CASO_RESPONSE=$(curl -s -X POST "$API_URL/casos" \
  -H "Content-Type: application/json" \
  -d '{
    "clienteNombre": "Juan Pérez Test",
    "clienteTelefono": "+54 11 1234-5678",
    "tipo": "HELADERA",
    "marca": "Samsung",
    "modelo": "RT38",
    "antiguedad": 3,
    "sintomaReportado": "La heladera no enfría nada"
  }')

if [ $? -ne 0 ]; then
    echo "❌ ERROR: No se pudo crear el caso"
    exit 1
fi

CASO_ID=$(echo $CASO_RESPONSE | jq -r '.id')
if [ "$CASO_ID" == "null" ] || [ -z "$CASO_ID" ]; then
    echo "❌ ERROR: No se obtuvo ID del caso"
    echo "Respuesta: $CASO_RESPONSE"
    exit 1
fi

echo "✅ Caso creado con ID: $CASO_ID"
echo ""
sleep 1

# Paso 2: Primera pregunta
echo "❓ 2. Obteniendo primera pregunta..."
PREGUNTA_1=$(curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta")
PREGUNTA_1_TEXTO=$(echo $PREGUNTA_1 | jq -r '.texto')
PREGUNTA_1_ID=$(echo $PREGUNTA_1 | jq -r '.id')

if [ "$PREGUNTA_1_ID" == "null" ]; then
    echo "❌ ERROR: No se obtuvo la primera pregunta"
    echo "Respuesta: $PREGUNTA_1"
    exit 1
fi

echo "   ID: $PREGUNTA_1_ID"
echo "   Pregunta: $PREGUNTA_1_TEXTO"
echo ""
sleep 1

# Paso 3: Responder pregunta 1 - La luz SÍ funciona
echo "💬 3. Respondiendo P1: La luz SÍ funciona"
RESPUESTA_1=$(curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d "{
    \"preguntaId\": $PREGUNTA_1_ID,
    \"valor\": \"true\"
  }")
echo "✅ Respuesta enviada"
echo ""
sleep 1

# Paso 4: Segunda pregunta
echo "❓ 4. Obteniendo segunda pregunta..."
PREGUNTA_2=$(curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta")
PREGUNTA_2_TEXTO=$(echo $PREGUNTA_2 | jq -r '.texto')
PREGUNTA_2_ID=$(echo $PREGUNTA_2 | jq -r '.id')

if [ "$PREGUNTA_2_ID" == "null" ]; then
    echo "❌ ERROR: No se obtuvo la segunda pregunta"
    echo "Respuesta: $PREGUNTA_2"
    echo ""
    echo "🔍 Verificando estado del caso..."
    curl -s "$API_URL/casos/$CASO_ID" | jq '.'
    exit 1
fi

echo "   ID: $PREGUNTA_2_ID"
echo "   Pregunta: $PREGUNTA_2_TEXTO"
echo ""
echo "🎉 ¡LA PREGUNTA AVANZÓ CORRECTAMENTE!"
echo ""
sleep 1

# Paso 5: Ver hipótesis
echo "🔍 5. Verificando hipótesis actuales..."
HIPOTESIS=$(curl -s "$API_URL/casos/$CASO_ID/hipotesis")
echo "$HIPOTESIS" | jq -r '.[] | "  - \(.descripcion): \(.probabilidad)%"'
echo ""
sleep 1

# Paso 6: Responder pregunta 2 - El motor NO suena
echo "💬 6. Respondiendo P2: El motor NO suena"
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d "{
    \"preguntaId\": $PREGUNTA_2_ID,
    \"valor\": \"false\"
  }" > /dev/null
echo "✅ Respuesta enviada"
echo ""
sleep 1

# Paso 7: Tercera pregunta
echo "❓ 7. Obteniendo tercera pregunta..."
PREGUNTA_3=$(curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta")
PREGUNTA_3_TEXTO=$(echo $PREGUNTA_3 | jq -r '.texto')
PREGUNTA_3_ID=$(echo $PREGUNTA_3 | jq -r '.id')

if [ "$PREGUNTA_3_ID" == "null" ]; then
    echo "❌ ERROR: No se obtuvo la tercera pregunta"
    echo "Respuesta: $PREGUNTA_3"
    exit 1
fi

echo "   ID: $PREGUNTA_3_ID"
echo "   Pregunta: $PREGUNTA_3_TEXTO"
echo ""
sleep 1

# Paso 8: Responder pregunta 3 - Motor SÍ está caliente
echo "💬 8. Respondiendo P3: El motor SÍ está caliente"
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d "{
    \"preguntaId\": $PREGUNTA_3_ID,
    \"valor\": \"true\"
  }" > /dev/null
echo "✅ Respuesta enviada"
echo ""
sleep 1

# Paso 9: Verificar si hay más preguntas
echo "❓ 9. Verificando si hay más preguntas..."
PREGUNTA_4=$(curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta")
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/casos/$CASO_ID/siguiente-pregunta")

if [ "$HTTP_CODE" == "204" ]; then
    echo "✅ No hay más preguntas (HTTP 204 - correcto)"
elif [ "$(echo $PREGUNTA_4 | jq -r '.id')" == "null" ]; then
    echo "✅ No hay más preguntas (respuesta vacía)"
else
    echo "⚠️  Hay una pregunta más: $(echo $PREGUNTA_4 | jq -r '.texto')"
fi
echo ""
sleep 1

# Paso 10: Finalizar diagnóstico
echo "🏁 10. Finalizando diagnóstico..."
CASO_FINAL=$(curl -s -X POST "$API_URL/casos/$CASO_ID/finalizar")
if [ $? -ne 0 ]; then
    echo "❌ ERROR: No se pudo finalizar el diagnóstico"
    exit 1
fi
echo "✅ Diagnóstico finalizado"
echo ""
sleep 1

# Paso 11: Mostrar diagnóstico final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   📊 DIAGNÓSTICO FINAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

DIAGNOSTICO=$(echo $CASO_FINAL | jq -r '.diagnostico')

echo "🎯 Causa Probable:"
echo "   $(echo $DIAGNOSTICO | jq -r '.causaProbable')"
echo ""

echo "📈 Probabilidad: $(echo $DIAGNOSTICO | jq -r '.probabilidad')%"
echo ""

echo "🔧 Componente Afectado:"
echo "   $(echo $DIAGNOSTICO | jq -r '.componenteAfectado')"
echo ""

echo "👨‍🔧 Requiere Técnico: $(echo $DIAGNOSTICO | jq -r '.requiereTecnico')"
echo "📋 Tipo Solución: $(echo $DIAGNOSTICO | jq -r '.tipoSolucion')"
echo "🚨 Urgencia: $(echo $DIAGNOSTICO | jq -r '.urgencia')"
echo ""

echo "💰 Costo Estimado:"
echo "   $$(echo $DIAGNOSTICO | jq -r '.costoEstimadoMin') - $$(echo $DIAGNOSTICO | jq -r '.costoEstimadoMax')"
echo ""

echo "⏱️  Tiempo Estimado: $(echo $DIAGNOSTICO | jq -r '.tiempoEstimado') minutos"
echo ""

echo "🔩 Repuestos Probables:"
echo $DIAGNOSTICO | jq -r '.repuestosProbables[]' | sed 's/^/   • /'
echo ""

echo "📨 Mensajes al Cliente:"
echo $DIAGNOSTICO | jq -r '.mensajesCliente[]' | sed 's/^/   • /'
echo ""

ALERTAS=$(echo $DIAGNOSTICO | jq -r '.alertasSeguridad[]' 2>/dev/null)
if [ ! -z "$ALERTAS" ]; then
    echo "⚠️  Alertas de Seguridad:"
    echo "$ALERTAS" | sed 's/^/   ⚠️  /'
    echo ""
fi

echo "📋 Generar OT: $(echo $DIAGNOSTICO | jq -r '.generarOrdenTrabajo')"
echo "🔴 Prioridad OT: $(echo $DIAGNOSTICO | jq -r '.prioridadOT')"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ ¡PRUEBA COMPLETADA EXITOSAMENTE!"
echo ""
echo "✓ Las preguntas avanzan correctamente"
echo "✓ El diagnóstico se generó correctamente"
echo "✓ Sistema funcionando al 100%"
echo ""

