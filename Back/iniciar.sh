#!/bin/bash

# Script para iniciar el Sistema Experto con base de datos persistente

echo "╔════════════════════════════════════════════════════╗"
echo "║     SISTEMA EXPERTO - INICIANDO APLICACIÓN        ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: Este script debe ejecutarse desde el directorio del proyecto"
    echo "   Ejecuta: cd /Users/matiasabate/Documents/IA/Back"
    exit 1
fi

echo "📁 Directorio: $(pwd)"
echo ""

# Crear directorio para la base de datos si no existe
if [ ! -d "data" ]; then
    echo "📂 Creando directorio para la base de datos..."
    mkdir -p data
    echo "   ✅ Directorio 'data' creado"
fi
echo ""

echo "🔨 Compilando el proyecto..."
mvn clean compile -q
if [ $? -eq 0 ]; then
    echo "   ✅ Compilación exitosa"
else
    echo "   ❌ Error en la compilación"
    exit 1
fi
echo ""

echo "════════════════════════════════════════════════════"
echo "🚀 INICIANDO APLICACIÓN..."
echo "════════════════════════════════════════════════════"
echo ""
echo "📌 Endpoints disponibles:"
echo "   • API REST:      http://localhost:8080/api/casos"
echo "   • Consola H2:    http://localhost:8080/h2-console"
echo ""
echo "💾 Base de datos: ./data/sistemaexperto.mv.db"
echo ""
echo "⏹️  Para detener: Presiona Ctrl+C"
echo ""
echo "════════════════════════════════════════════════════"
echo ""

# Ejecutar la aplicación
mvn spring-boot:run

