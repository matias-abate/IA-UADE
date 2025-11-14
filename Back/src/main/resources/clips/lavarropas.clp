; ============================================
; REGLAS DE DIAGNÓSTICO - LAVARROPAS
; ============================================

; Regla 6: Lavarropas no carga agua - Verificación suministro
(defrule lavarropas-no-carga-agua-sin-suministro
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo lavarropas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no carga agua" ?desc) (str-index "no carga" ?desc)))
  (respuesta (caso-id ?id) (pregunta "llave-paso-abierta") (valor si))
  (respuesta (caso-id ?id) (pregunta "sale-agua-canilla") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Problema de suministro de agua - No es falla del lavarropas")
    (probabilidad 95)
    (componente-afectado "Ninguno")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia media)
    (requiere-tecnico no)
    (justificacion "Problema externo - Revisar suministro de agua")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Verificar suministro de agua")
    (pasos "1. Verificar si hay agua en otras canillas | 2. Revisar si hay corte de agua | 3. Verificar llave de paso específica del lavarropas | 4. Si el problema persiste, contactar plomero")
    (tiempo-estimado 5)
    (costo-estimado 0)))
)

(defrule lavarropas-no-carga-agua-filtro-electrovalvula
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo lavarropas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no carga agua" ?desc) (str-index "no carga" ?desc)))
  (respuesta (caso-id ?id) (pregunta "sale-agua-canilla") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Filtro de entrada tapado o electroválvula defectuosa")
    (probabilidad 80)
    (componente-afectado "Filtro/Electroválvula")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia media)
    (requiere-tecnico no)
    (justificacion "Primero intentar limpieza de filtro (DIY), si no resuelve requiere técnico")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Limpieza de filtro de entrada")
    (pasos "1. Cerrar llave de paso | 2. Desconectar manguera de entrada del lavarropas | 3. Retirar filtro (pequeña rejilla) con pinza | 4. Limpiar bajo agua | 5. Reinstalar y probar | 6. Si no resuelve, el problema es la electroválvula - REQUIERE TÉCNICO")
    (tiempo-estimado 15)
    (costo-estimado 0)))
)

; Regla 7: Lavarropas no desagota - Bomba o filtro
(defrule lavarropas-no-desagota
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo lavarropas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no desagota" ?desc) (str-index "no desagua" ?desc) (str-index "agua dentro" ?desc)))
  (respuesta (caso-id ?id) (pregunta "lava-normalmente") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Filtro de bomba obstruido o bomba defectuosa")
    (probabilidad 85)
    (componente-afectado "Filtro bomba/Bomba desagüe")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia alta)
    (requiere-tecnico no)
    (justificacion "Primero limpiar filtro (DIY), si no resuelve requiere técnico")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Limpieza de filtro de bomba")
    (pasos "1. Ubicar filtro (parte frontal inferior, tapa pequeña) | 2. Colocar bandeja/toallas para agua | 3. Girar filtro lentamente para desaguar | 4. Quitar completamente y limpiar (monedas, botones, pelos) | 5. Reinstalar y probar | 6. Si sigue sin desagotar: bomba defectuosa - REQUIERE TÉCNICO")
    (tiempo-estimado 20)
    (costo-estimado 0)))
  (printout t "DIAGNÓSTICO: Filtro obstruido - Cliente puede intentar limpieza" crlf)
)

; Regla 8: Lavarropas no centrifuga
(defrule lavarropas-no-centrifuga
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo lavarropas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no centrifuga" ?desc) (str-index "no centrifuga" ?desc)))
  (respuesta (caso-id ?id) (pregunta "lava-normalmente") (valor si))
  (respuesta (caso-id ?id) (pregunta "desagota") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Problema en programador, correa o motor")
    (probabilidad 70)
    (componente-afectado "Programador/Correa/Motor")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia media)
    (requiere-tecnico si)
    (justificacion "Requiere revisión técnica - Múltiples causas posibles")))
  (assert (orden-trabajo
    (numero (+ ?id 1000))
    (caso-id ?id)
    (prioridad media)
    (diagnostico-preliminar "No centrifuga pero lava y desagota - Verificar correa, programador y carbones del motor")
    (repuestos-probables "Correa, Carbones motor, Programador")
    (herramientas-necesarias "Destornillador, Multímetro")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Reparación técnica - Correa o motor")
    (pasos "Técnico verificará: 1. Estado de correa | 2. Carbones del motor | 3. Programador | Reparación según hallazgo")
    (tiempo-estimado 60)
    (costo-estimado 35000)))
)

; Regla 9: Lavarropas vibra - Equipo nuevo sin tornillos transporte removidos
(defrule lavarropas-vibra-nuevo
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo lavarropas) (antiguedad ?años))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "vibra" ?desc) (str-index "vibración" ?desc) (str-index "mueve" ?desc)))
  (test (< ?años 1))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Tornillos de transporte no removidos")
    (probabilidad 90)
    (componente-afectado "Tornillos transporte")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia alta)
    (requiere-tecnico no)
    (justificacion "Problema común en instalación - Simple de resolver")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Remoción de tornillos de transporte")
    (pasos "1. Desconectar lavarropas | 2. Mover para acceder a parte trasera | 3. Localizar 3-4 tornillos grandes con resortes | 4. Quitar con llave inglesa | 5. GUARDAR en lugar seguro (necesarios para mudanzas) | 6. Tapar orificios con tapones plásticos incluidos | 7. Nivelar equipo")
    (tiempo-estimado 15)
    (costo-estimado 0)))
  (printout t "DIAGNÓSTICO: Tornillos de transporte - SOLUCIÓN INMEDIATA DIY" crlf)
)

; Regla 10: Lavarropas vibra - Desbalanceo de carga
(defrule lavarropas-vibra-desbalanceo
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo lavarropas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "vibra" ?desc) (str-index "vibración" ?desc)))
  (respuesta (caso-id ?id) (pregunta "ocurre-con-cualquier-carga") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Desbalanceo de carga - Mal uso")
    (probabilidad 95)
    (componente-afectado "Ninguno")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia baja)
    (requiere-tecnico no)
    (justificacion "Educación de uso correcto")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Consejos de carga correcta")
    (pasos "1. No sobrecargar (máx 80% capacidad) | 2. No lavar prendas muy pesadas solas (ej: una frazada) | 3. Mezclar prendas grandes y pequeñas | 4. Verificar nivelación del lavarropas con nivel de burbuja | 5. Ajustar patas si es necesario")
    (tiempo-estimado 5)
    (costo-estimado 0)))
)

