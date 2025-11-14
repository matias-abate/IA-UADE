#!/bin/bash

# Script de prueba del sistema de diagnóstico
# Prueba el flujo completo para Heladera No Enfría

echo "🧪 SISTEMA DE DIAGNÓSTICO - PRUEBA COMPLETA"
echo "=========================================="
echo ""

API_URL="http://localhost:8080/api"

echo "📝 1. Creando caso: Heladera no enfría..."
CASO_RESPONSE=$(curl -s -X POST "$API_URL/casos" \
  -H "Content-Type: application/json" \
  -d '{
    "clienteNombre": "Juan Pérez",
    "clienteTelefono": "+54 11 1234-5678",
    "tipo": "HELADERA",
    "marca": "Samsung",
    "modelo": "RT38",
    "antiguedad": 3,
    "sintomaReportado": "La heladera no enfría nada"
  }')

CASO_ID=$(echo $CASO_RESPONSE | jq -r '.id')
echo "✅ Caso creado con ID: $CASO_ID"
echo ""

sleep 1

echo "❓ 2. Obteniendo primera pregunta..."
PREGUNTA=$(curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta")
echo "Pregunta: $(echo $PREGUNTA | jq -r '.texto')"
echo ""

sleep 1

echo "💬 3. Respondiendo: La luz SÍ funciona"
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d '{
    "preguntaId": 1,
    "valor": "true"
  }' > /dev/null
echo "✅ Respuesta enviada"
echo ""

sleep 1

echo "🔍 4. Verificando hipótesis actuales..."
HIPOTESIS=$(curl -s "$API_URL/casos/$CASO_ID/hipotesis")
echo "$HIPOTESIS" | jq -r '.[] | "  - \(.descripcion): \(.probabilidad)%"'
echo ""

sleep 1

echo "❓ 5. Obteniendo segunda pregunta..."
PREGUNTA=$(curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta")
echo "Pregunta: $(echo $PREGUNTA | jq -r '.texto')"
echo ""

sleep 1

echo "💬 6. Respondiendo: El motor NO suena"
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d '{
    "preguntaId": 2,
    "valor": "false"
  }' > /dev/null
echo "✅ Respuesta enviada"
echo ""

sleep 1

echo "❓ 7. Obteniendo tercera pregunta..."
PREGUNTA=$(curl -s "$API_URL/casos/$CASO_ID/siguiente-pregunta")
echo "Pregunta: $(echo $PREGUNTA | jq -r '.texto')"
echo ""

sleep 1

echo "💬 8. Respondiendo: El motor SÍ está caliente"
curl -s -X POST "$API_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d '{
    "preguntaId": 3,
    "valor": "true"
  }' > /dev/null
echo "✅ Respuesta enviada"
echo ""

sleep 1

echo "🏁 9. Finalizando diagnóstico..."
curl -s -X POST "$API_URL/casos/$CASO_ID/finalizar" > /dev/null
echo "✅ Diagnóstico finalizado"
echo ""

sleep 1

echo "📊 10. Obteniendo diagnóstico final..."
CASO_FINAL=$(curl -s "$API_URL/casos/$CASO_ID")
echo ""
echo "════════════════ DIAGNÓSTICO FINAL ════════════════"
echo "Causa Probable: $(echo $CASO_FINAL | jq -r '.diagnostico.causaProbable')"
echo "Probabilidad: $(echo $CASO_FINAL | jq -r '.diagnostico.probabilidad')%"
echo "Componente: $(echo $CASO_FINAL | jq -r '.diagnostico.componenteAfectado')"
echo "Requiere Técnico: $(echo $CASO_FINAL | jq -r '.diagnostico.requiereTecnico')"
echo "Tipo Solución: $(echo $CASO_FINAL | jq -r '.diagnostico.tipoSolucion')"
echo "Urgencia: $(echo $CASO_FINAL | jq -r '.diagnostico.urgencia')"
echo "Costo Estimado: $$(echo $CASO_FINAL | jq -r '.diagnostico.costoEstimadoMin') - $$(echo $CASO_FINAL | jq -r '.diagnostico.costoEstimadoMax')"
echo "Tiempo Estimado: $(echo $CASO_FINAL | jq -r '.diagnostico.tiempoEstimado') minutos"
echo ""
echo "Repuestos Probables:"
echo $CASO_FINAL | jq -r '.diagnostico.repuestosProbables[]' | sed 's/^/  - /'
echo ""
echo "Mensajes al Cliente:"
echo $CASO_FINAL | jq -r '.diagnostico.mensajesCliente[]' | sed 's/^/  - /'
echo ""
echo "Alertas de Seguridad:"
echo $CASO_FINAL | jq -r '.diagnostico.alertasSeguridad[]' | sed 's/^/  ⚠️  /'
echo ""
echo "Generar OT: $(echo $CASO_FINAL | jq -r '.diagnostico.generarOrdenTrabajo')"
echo "Prioridad OT: $(echo $CASO_FINAL | jq -r '.diagnostico.prioridadOT')"
echo "═══════════════════════════════════════════════════"
echo ""
echo "✅ PRUEBA COMPLETADA EXITOSAMENTE"

