; ============================================
; REGLAS DE SEGURIDAD Y PREVENCIÓN
; ============================================

; Regla de seguridad: Equipo muy antiguo
(defrule equipo-muy-antiguo
  (caso (id ?id))
  (electrodomestico (tipo ?tipo) (antiguedad ?años))
  (test (> ?años 15))
  =>
  (printout t "⚠ AVISO: Equipo con más de 15 años - Considerar reemplazo por eficiencia energética y seguridad" crlf)
  (assert (recomendacion
    (caso-id ?id)
    (tipo prevencion)
    (mensaje "Equipos con más de 15 años tienen mayor riesgo de fallas graves y consumen más energía. Evaluar costo/beneficio de reemplazo.")))
)

; Regla de seguridad: Riesgo eléctrico
(defrule alerta-riesgo-electrico
  (diagnostico (caso-id ?id) (componente-afectado ?comp))
  (test (or (str-index "Circuito" ?comp)
            (str-index "Cable" ?comp)
            (str-index "Enchufe" ?comp)
            (str-index "Eléctrico" ?comp)))
  =>
  (printout t "⚠ ALERTA DE SEGURIDAD: Posible riesgo eléctrico - No manipular sin conocimientos" crlf)
  (assert (alerta-seguridad
    (caso-id ?id)
    (tipo riesgo-electrico)
    (mensaje "PRECAUCIÓN: No manipular cables o componentes eléctricos sin desconectar primero. Si no tiene conocimientos, llamar electricista.")))
)

; Regla: Costo de reparación vs reemplazo
(defrule evaluar-reemplazo
  (caso (id ?id))
  (electrodomestico (tipo ?tipo) (antiguedad ?años))
  (solucion (caso-id ?id) (costo-estimado ?costo))
  (test (and (> ?años 7) (> ?costo 80000)))
  =>
  (printout t "💡 RECOMENDACIÓN: Evaluar compra de equipo nuevo - Reparación costosa en equipo antiguo" crlf)
  (assert (recomendacion
    (caso-id ?id)
    (tipo economica)
    (mensaje "Con más de 7 años y costo de reparación alto, suele convenir más comprar equipo nuevo con garantía y mejor eficiencia energética.")))
)

; Regla: Prevención - Mantenimiento periódico heladera
(defrule mantenimiento-heladera
  (caso (id ?id))
  (electrodomestico (tipo heladera))
  (decision (caso-id ?id) (requiere-tecnico no))
  =>
  (assert (consejo-mantenimiento
    (caso-id ?id)
    (periodicidad "Cada 6 meses")
    (acciones "1. Limpiar serpentina trasera con aspiradora | 2. Verificar gomas de puerta | 3. Limpiar desagüe con agua tibia | 4. Regular temperatura (3-5°C refrigerador, -18°C freezer) | 5. No sobrecargar")))
)

; Regla: Prevención - Mantenimiento periódico lavarropas
(defrule mantenimiento-lavarropas
  (caso (id ?id))
  (electrodomestico (tipo lavarropas))
  (decision (caso-id ?id) (requiere-tecnico no))
  =>
  (assert (consejo-mantenimiento
    (caso-id ?id)
    (periodicidad "Mensual")
    (acciones "1. Limpiar filtro de bomba | 2. Limpiar cajón de detergente | 3. Dejar puerta abierta después de usar (evita hongos) | 4. Ciclo limpieza en vacío con vinagre (250ml) cada 2 meses | 5. No exceder capacidad")))
)

; Regla: Prevención - Mantenimiento microondas
(defrule mantenimiento-microondas
  (caso (id ?id))
  (electrodomestico (tipo microondas))
  (decision (caso-id ?id) (requiere-tecnico no))
  =>
  (assert (consejo-mantenimiento
    (caso-id ?id)
    (periodicidad "Semanal")
    (acciones "1. Limpiar interior con paño húmedo | 2. Limpiar mica si hay salpicaduras | 3. NO usar productos abrasivos | 4. Verificar que plato gire libremente | 5. NUNCA encender vacío | 6. NO usar metales, aluminio ni plásticos no aptos")))
)

