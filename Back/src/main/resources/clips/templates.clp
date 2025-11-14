; ============================================
; PLANTILLAS DE DATOS - SISTEMA EXPERTO
; ============================================
; Este archivo contiene todas las plantillas (deftemplate)
; necesarias para el sistema de diagnóstico

; Información del cliente y caso
(deftemplate caso
  (slot id (type INTEGER))
  (slot fecha (type STRING))
  (slot cliente (type STRING))
  (slot telefono (type STRING))
  (slot direccion (type STRING))
  (slot estado (allowed-values abierto en-diagnostico resuelto-remoto requiere-tecnico cerrado))
)

; Electrodoméstico afectado
(deftemplate electrodomestico
  (slot tipo (allowed-values heladera lavarropas microondas))
  (slot marca (type STRING))
  (slot modelo (type STRING))
  (slot antiguedad (type INTEGER)) ; en años
  (slot en-garantia (type SYMBOL) (allowed-values si no))
)

; Síntomas reportados
(deftemplate sintoma
  (slot caso-id (type INTEGER))
  (slot descripcion (type STRING))
  (slot gravedad (allowed-values baja media alta critica))
)

; Respuestas a preguntas diagnósticas
(deftemplate respuesta
  (slot caso-id (type INTEGER))
  (slot pregunta (type STRING))
  (slot valor (type SYMBOL))
)

; Diagnóstico generado
(deftemplate diagnostico
  (slot caso-id (type INTEGER))
  (slot causa-probable (type STRING))
  (slot probabilidad (type INTEGER)) ; 0-100
  (slot componente-afectado (type STRING))
)

; Decisión de resolución
(deftemplate decision
  (slot caso-id (type INTEGER))
  (slot tipo (allowed-values diy tecnico-simple tecnico-complejo reemplazo))
  (slot urgencia (allowed-values baja media alta critica))
  (slot requiere-tecnico (type SYMBOL) (allowed-values si no))
  (slot justificacion (type STRING))
)

; Solución propuesta
(deftemplate solucion
  (slot caso-id (type INTEGER))
  (slot descripcion (type STRING))
  (slot pasos (type STRING))
  (slot tiempo-estimado (type INTEGER)) ; en minutos
  (slot costo-estimado (type INTEGER)) ; en pesos
)

; Orden de trabajo para técnico
(deftemplate orden-trabajo
  (slot numero (type INTEGER))
  (slot caso-id (type INTEGER))
  (slot tecnico-asignado (type STRING))
  (slot prioridad (allowed-values baja media alta urgente))
  (slot diagnostico-preliminar (type STRING))
  (slot repuestos-probables (type STRING))
  (slot herramientas-necesarias (type STRING))
)

; Métricas para el dashboard
(deftemplate metrica
  (slot tipo (allowed-values resolucion-remota despacho-tecnico tiempo-diagnostico satisfaccion-cliente))
  (slot valor (type NUMBER))
  (slot fecha (type STRING))
)

; Recomendaciones
(deftemplate recomendacion
  (slot caso-id (type INTEGER))
  (slot tipo (allowed-values prevencion economica seguridad))
  (slot mensaje (type STRING))
)

; Alertas de seguridad
(deftemplate alerta-seguridad
  (slot caso-id (type INTEGER))
  (slot tipo (allowed-values riesgo-electrico riesgo-gas riesgo-incendio))
  (slot mensaje (type STRING))
)

; Consejos de mantenimiento
(deftemplate consejo-mantenimiento
  (slot caso-id (type INTEGER))
  (slot periodicidad (type STRING))
  (slot acciones (type STRING))
)

