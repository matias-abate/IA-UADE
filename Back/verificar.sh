#!/bin/bash

echo "🔍 VERIFICACIÓN DEL SISTEMA"
echo "=========================="
echo ""

# 1. Verificar Java
echo "1️⃣  Verificando Java..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    echo "   ✅ Java instalado: $JAVA_VERSION"
else
    echo "   ❌ Java NO encontrado"
    exit 1
fi
echo ""

# 2. Verificar Maven
echo "2️⃣  Verificando Maven..."
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn -version | head -n 1)
    echo "   ✅ $MVN_VERSION"
else
    echo "   ❌ Maven NO encontrado"
    exit 1
fi
echo ""

# 3. Verificar archivos del proyecto
echo "3️⃣  Verificando archivos del proyecto..."
if [ -f "pom.xml" ]; then
    echo "   ✅ pom.xml encontrado"
else
    echo "   ❌ pom.xml NO encontrado"
    exit 1
fi

if [ -f "src/main/resources/application.properties" ]; then
    echo "   ✅ application.properties encontrado"
else
    echo "   ❌ application.properties NO encontrado"
    exit 1
fi
echo ""

# 4. Verificar configuración de BD
echo "4️⃣  Verificando configuración de base de datos..."
if grep -q "jdbc:h2:file:./data/sistemaexperto" src/main/resources/application.properties; then
    echo "   ✅ Base de datos configurada en modo archivo"
else
    echo "   ⚠️  Advertencia: Configuración de BD inesperada"
fi

if grep -q "ddl-auto=update" src/main/resources/application.properties; then
    echo "   ✅ Modo de persistencia configurado (update)"
else
    echo "   ⚠️  Advertencia: Modo de persistencia inesperado"
fi
echo ""

# 5. Verificar compilación
echo "5️⃣  Probando compilación..."
mvn clean compile -q
if [ $? -eq 0 ]; then
    echo "   ✅ Compilación exitosa"
else
    echo "   ❌ Error en la compilación"
    exit 1
fi
echo ""

# 6. Verificar puerto 8080
echo "6️⃣  Verificando puerto 8080..."
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "   ⚠️  Puerto 8080 está en uso"
    echo "      Para liberar: lsof -ti:8080 | xargs kill -9"
else
    echo "   ✅ Puerto 8080 disponible"
fi
echo ""

# 7. Resumen
echo "════════════════════════════════════════"
echo "✅ VERIFICACIÓN COMPLETADA"
echo "════════════════════════════════════════"
echo ""
echo "📋 Todo está listo para ejecutar:"
echo ""
echo "   ./iniciar.sh"
echo ""
echo "   O manualmente:"
echo "   mvn spring-boot:run"
echo ""
echo "════════════════════════════════════════"

