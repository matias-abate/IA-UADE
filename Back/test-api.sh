#!/bin/bash
# Script de prueba del API del Sistema Experto

BASE_URL="http://localhost:8080/api"

echo "======================================"
echo "Sistema Experto - Pruebas de API"
echo "======================================"
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Listar todos los casos
echo -e "${BLUE}1. Listar todos los casos:${NC}"
curl -s -X GET "$BASE_URL/casos" | jq .
echo ""
echo ""

# 2. Crear un nuevo caso
echo -e "${BLUE}2. Crear un nuevo caso:${NC}"
NUEVO_CASO=$(curl -s -X POST "$BASE_URL/casos" \
  -H "Content-Type: application/json" \
  -d '{
    "descripcion": "Heladera hace ruido extraño",
    "tipoElectrodomestico": "HELADERA",
    "modelo": "Samsung RT35",
    "antiguedad": 4
  }')
echo "$NUEVO_CASO" | jq .
CASO_ID=$(echo "$NUEVO_CASO" | jq -r '.id')
echo -e "${GREEN}Caso creado con ID: $CASO_ID${NC}"
echo ""
echo ""

# 3. Obtener caso por ID
echo -e "${BLUE}3. Obtener caso por ID ($CASO_ID):${NC}"
curl -s -X GET "$BASE_URL/casos/$CASO_ID" | jq .
echo ""
echo ""

# 4. Obtener siguiente pregunta
echo -e "${BLUE}4. Obtener siguiente pregunta:${NC}"
PREGUNTA=$(curl -s -X GET "$BASE_URL/casos/$CASO_ID/siguiente-pregunta")
echo "$PREGUNTA" | jq .
PREGUNTA_ID=$(echo "$PREGUNTA" | jq -r '.id')
echo ""
echo ""

# 5. Responder pregunta
echo -e "${BLUE}5. Responder pregunta (ID: $PREGUNTA_ID):${NC}"
curl -s -X POST "$BASE_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d "{
    \"preguntaId\": $PREGUNTA_ID,
    \"valor\": \"si\"
  }" | jq .
echo ""
echo ""

# 6. Ver hipótesis actuales
echo -e "${BLUE}6. Ver hipótesis actuales:${NC}"
curl -s -X GET "$BASE_URL/casos/$CASO_ID/hipotesis" | jq .
echo ""
echo ""

# 7. Obtener siguiente pregunta (después de responder)
echo -e "${BLUE}7. Obtener siguiente pregunta:${NC}"
PREGUNTA2=$(curl -s -X GET "$BASE_URL/casos/$CASO_ID/siguiente-pregunta")
echo "$PREGUNTA2" | jq .
PREGUNTA_ID2=$(echo "$PREGUNTA2" | jq -r '.id')
echo ""
echo ""

# 8. Responder segunda pregunta
echo -e "${BLUE}8. Responder segunda pregunta (ID: $PREGUNTA_ID2):${NC}"
curl -s -X POST "$BASE_URL/casos/$CASO_ID/responder" \
  -H "Content-Type: application/json" \
  -d "{
    \"preguntaId\": $PREGUNTA_ID2,
    \"valor\": \"no\"
  }" | jq .
echo ""
echo ""

# 9. Finalizar diagnóstico
echo -e "${BLUE}9. Finalizar diagnóstico:${NC}"
curl -s -X POST "$BASE_URL/casos/$CASO_ID/finalizar" | jq .
echo ""
echo ""

# 10. Obtener caso completo con diagnóstico
echo -e "${BLUE}10. Obtener caso completo con diagnóstico:${NC}"
curl -s -X GET "$BASE_URL/casos/$CASO_ID" | jq .
echo ""
echo ""

echo -e "${GREEN}======================================"
echo "Pruebas completadas!"
echo "======================================${NC}"

