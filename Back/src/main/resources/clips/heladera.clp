; ============================================
; REGLAS DE DIAGNÓSTICO - HELADERA
; ============================================

; Regla 1: Heladera no enfría - Verificación eléctrica básica
(defrule heladera-no-enfria-luz-no-funciona
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc) (gravedad ?grav))
  (test (or (str-index "no enfria" ?desc) (str-index "no enfría" ?desc) (str-index "no funciona" ?desc)))
  (respuesta (caso-id ?id) (pregunta "1") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Problema eléctrico - Sin alimentación")
    (probabilidad 85)
    (componente-afectado "Circuito eléctrico/Enchufe/Fusible")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia alta)
    (requiere-tecnico no)
    (justificacion "Verificar conexión eléctrica, fusible y tablero")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Verificación eléctrica básica")
    (pasos "1. Verificar enchufe bien conectado | 2. Probar con otro electrodoméstico en el mismo enchufe | 3. Revisar fusibles del tablero | 4. Si nada funciona, problema del circuito - requiere electricista")
    (tiempo-estimado 10)
    (costo-estimado 0)))
  (printout t "DIAGNÓSTICO: Problema eléctrico básico - Solución DIY" crlf)
)

; Regla 2: Heladera no enfría - Compresor no arranca
(defrule heladera-no-enfria-compresor-no-arranca
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no enfria" ?desc) (str-index "no enfría" ?desc)))
  (respuesta (caso-id ?id) (pregunta "1") (valor si))
  (respuesta (caso-id ?id) (pregunta "2") (valor no))
  (respuesta (caso-id ?id) (pregunta "3") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Compresor defectuoso o relé de arranque fallado")
    (probabilidad 75)
    (componente-afectado "Compresor/Relé de arranque")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-complejo)
    (urgencia alta)
    (requiere-tecnico si)
    (justificacion "Falla en compresor - Requiere técnico especializado")))
  (assert (orden-trabajo
    (numero (+ ?id 1000))
    (caso-id ?id)
    (prioridad urgente)
    (diagnostico-preliminar "Compresor no arranca - posible falla en compresor o relé")
    (repuestos-probables "Compresor, Relé de arranque, Protector térmico")
    (herramientas-necesarias "Multímetro, Pinza amperométrica, Kit refrigeración")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Reemplazo de compresor o relé")
    (pasos "ACCIÓN INMEDIATA: Trasladar alimentos perecederos. Técnico evaluará si es compresor (costo alto) o relé (costo bajo).")
    (tiempo-estimado 180)
    (costo-estimado 120000)))
  (printout t "DIAGNÓSTICO: Falla en compresor - REQUIERE TÉCNICO URGENTE" crlf)
)

; Regla 3: Heladera no enfría - Termostato defectuoso
(defrule heladera-no-enfria-termostato
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no enfria" ?desc) (str-index "no enfría" ?desc)))
  (respuesta (caso-id ?id) (pregunta "2") (valor si))
  (respuesta (caso-id ?id) (pregunta "4") (valor ?ciclo))
  (test (or (eq ?ciclo "Constantemente sin parar") (eq ?ciclo "constantemente")))
  (respuesta (caso-id ?id) (pregunta "5") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Termostato defectuoso - no corta el ciclo")
    (probabilidad 80)
    (componente-afectado "Termostato")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia media)
    (requiere-tecnico si)
    (justificacion "Reemplazo de termostato - Reparación simple")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Reemplazo de termostato")
    (pasos "Técnico reemplazará termostato. Reparación rápida.")
    (tiempo-estimado 45)
    (costo-estimado 25000)))
  (printout t "DIAGNÓSTICO: Termostato defectuoso - Técnico programado" crlf)
)

; Regla 4: Heladera pierde agua - Desagüe tapado (DIY)
(defrule heladera-pierde-agua-desague
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "pierde agua" ?desc) (str-index "gotea" ?desc) (str-index "agua" ?desc)))
  (respuesta (caso-id ?id) (pregunta "agua-ubicacion") (valor interior))
  (respuesta (caso-id ?id) (pregunta "hielo-excesivo") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Desagüe de descongelamiento obstruido")
    (probabilidad 90)
    (componente-afectado "Desagüe")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia baja)
    (requiere-tecnico no)
    (justificacion "Limpieza de desagüe - Cliente puede resolverlo")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Limpieza de desagüe de descongelamiento")
    (pasos "1. Desconectar heladera | 2. Ubicar orificio de desagüe (parte trasera interior del refrigerador) | 3. Con jeringa o pera de goma, inyectar agua tibia con un poco de vinagre | 4. Si no destapa, usar alambre flexible suavemente | 5. Reconectar y verificar")
    (tiempo-estimado 20)
    (costo-estimado 0)))
  (printout t "DIAGNÓSTICO: Desagüe tapado - SOLUCIÓN DIY (Cliente puede resolverlo)" crlf)
)

; Regla 5: Heladera hace ruido - Vibración normal vs anormal
(defrule heladera-ruido-vibracion
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera) (antiguedad ?años))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "hace ruido" ?desc) (str-index "ruido" ?desc) (str-index "vibra" ?desc)))
  (respuesta (caso-id ?id) (pregunta "tipo-ruido") (valor vibracion))
  (test (< ?años 2))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Heladera mal nivelada o en superficie irregular")
    (probabilidad 85)
    (componente-afectado "Nivelación/Patas")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia baja)
    (requiere-tecnico no)
    (justificacion "Ajuste de nivelación - Simple")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Nivelación de heladera")
    (pasos "1. Desconectar heladera | 2. Con nivel, verificar si está horizontal | 3. Ajustar patas delanteras girándolas | 4. Verificar que no haya objetos debajo o detrás | 5. Separar 10cm de la pared")
    (tiempo-estimado 15)
    (costo-estimado 0)))
)

; Regla 6: Heladera no enfría - No arranque (Termostato/Control)
(defrule heladera-no-enfria-no-arranca
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no enfria" ?desc) (str-index "no enfría" ?desc) (str-index "no funciona" ?desc)))
  (respuesta (caso-id ?id) (pregunta "1") (valor si))
  (respuesta (caso-id ?id) (pregunta "2") (valor no))
  (respuesta (caso-id ?id) (pregunta "3") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Termostato o control defectuoso - no activa el compresor")
    (probabilidad 70)
    (componente-afectado "Termostato/Placa electrónica")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia alta)
    (requiere-tecnico si)
    (justificacion "Falla de control - Requiere técnico especializado")))
  (assert (orden-trabajo
    (numero (+ ?id 1000))
    (caso-id ?id)
    (prioridad urgente)
    (diagnostico-preliminar "Compresor no arranca - posible falla en termostato o control")
    (repuestos-probables "Termostato o placa electrónica")
    (herramientas-necesarias "Multímetro, Herramientas básicas")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Reparación/reemplazo de termostato o placa de control")
    (pasos "Técnico revisará termostato y placa; reemplazo del componente defectuoso")
    (tiempo-estimado 60)
    (costo-estimado 25000)))
  (printout t "DIAGNÓSTICO: Falla de control - REQUIERE TÉCNICO URGENTE" crlf)
)

; Regla 7: Heladera no enfría - Evaporador congelado (Deshielo defectuoso)
(defrule heladera-no-enfria-evaporador-congelado
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no enfria" ?desc) (str-index "no enfría" ?desc)))
  (respuesta (caso-id ?id) (pregunta "2") (valor si))
  (respuesta (caso-id ?id) (pregunta "4") (valor ?ciclo))
  (test (or (eq ?ciclo "Constantemente sin parar") (eq ?ciclo "constantemente")))
  (respuesta (caso-id ?id) (pregunta "5") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Evaporador congelado - Falla en sistema de descongelamiento")
    (probabilidad 90)
    (componente-afectado "Sistema de descongelamiento")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia media)
    (requiere-tecnico si)
    (justificacion "Bloqueo por hielo - Necesita revisión técnica")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Descongelar manualmente y reparar sistema de deshielo")
    (pasos "1. Desconectar heladera 12h para derretir hielo | 2. Reemplazar o reparar resistencias/termostato de descongelamiento")
    (tiempo-estimado 60)
    (costo-estimado 20000)))
  (printout t "DIAGNÓSTICO: Evaporador congelado - REQUIERE SERVICIO TÉCNICO" crlf)
)

; Regla 8: Heladera no enfría - Bajo refrigerante / Fuga
(defrule heladera-no-enfria-bajo-refrigerante
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no enfria" ?desc) (str-index "no enfría" ?desc)))
  (respuesta (caso-id ?id) (pregunta "2") (valor si))
  (respuesta (caso-id ?id) (pregunta "4") (valor ?ciclo))
  (test (and (neq ?ciclo "Constantemente sin parar") (neq ?ciclo "constantemente")))
  (respuesta (caso-id ?id) (pregunta "5") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Nivel de refrigerante bajo o fuga en el circuito")
    (probabilidad 80)
    (componente-afectado "Circuito refrigerante")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-complejo)
    (urgencia alta)
    (requiere-tecnico si)
    (justificacion "Fuga de refrigerante - Requiere técnico especializado urgente")))
  (assert (orden-trabajo
    (numero (+ ?id 1000))
    (caso-id ?id)
    (prioridad urgente)
    (diagnostico-preliminar "Posible fuga de gas refrigerante - bajo rendimiento de enfriamiento")
    (repuestos-probables "Gas refrigerante, Filtro secador")
    (herramientas-necesarias "Manifold, Bomba de vacío, Detector de fugas")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Recarga de gas refrigerante y sellado de fuga")
    (pasos "1. Verificar presión de gas | 2. Reparar fuga si existe | 3. Realizar vacío y recargar refrigerante")
    (tiempo-estimado 120)
    (costo-estimado 80000)))
  (printout t "DIAGNÓSTICO: Bajo refrigerante - REQUIERE TÉCNICO URGENTE" crlf)
)

; Regla 9: Heladera pierde agua - Obstrucción por hielo en desagüe
(defrule heladera-pierde-agua-drenaje-congelado
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "pierde agua" ?desc) (str-index "gotea" ?desc) (str-index "agua" ?desc)))
  (respuesta (caso-id ?id) (pregunta "agua-ubicacion") (valor interior))
  (respuesta (caso-id ?id) (pregunta "hielo-excesivo") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Desagote obstruido por hielo - Falla de descongelamiento")
    (probabilidad 85)
    (componente-afectado "Desagüe/Descongelamiento")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia media)
    (requiere-tecnico si)
    (justificacion "Hielo obstruyendo desagüe - Necesita técnico")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Descongelar y limpiar desagüe obstruido")
    (pasos "1. Desconectar y vaciar heladera para descongelar completamente | 2. Limpiar conducto de desagüe | 3. Revisar sistema de descongelamiento")
    (tiempo-estimado 60)
    (costo-estimado 15000)))
  (printout t "DIAGNÓSTICO: Desagüe congelado - REQUIERE TÉCNICO" crlf)
)

; Regla 10: Heladera pierde agua - Bandeja de evaporación llena (DIY)
(defrule heladera-pierde-agua-bandeja
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "pierde agua" ?desc) (str-index "gotea" ?desc) (str-index "agua" ?desc)))
  (respuesta (caso-id ?id) (pregunta "agua-ubicacion") (valor exterior))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Bandeja de evaporación llena o mal colocada")
    (probabilidad 80)
    (componente-afectado "Bandeja de goteo")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia baja)
    (requiere-tecnico no)
    (justificacion "Bandeja llena - Cliente puede resolverlo")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Vaciar y recolocar bandeja de evaporación")
    (pasos "1. Desconectar heladera | 2. Extraer y vaciar bandeja de goteo | 3. Limpiar y reinstalar bandeja correctamente | 4. Verificar nivelación de la heladera")
    (tiempo-estimado 10)
    (costo-estimado 0)))
  (printout t "DIAGNÓSTICO: Bandeja de goteo llena - SOLUCIÓN DIY" crlf)
)

; Regla 11: Heladera hace ruido - Vibración en equipo antiguo
(defrule heladera-ruido-vibracion-antigua
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera) (antiguedad ?años))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "hace ruido" ?desc) (str-index "ruido" ?desc) (str-index "vibra" ?desc)))
  (respuesta (caso-id ?id) (pregunta "tipo-ruido") (valor vibracion))
  (test (>= ?años 2))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Vibraciones por desgaste de componentes")
    (probabilidad 80)
    (componente-afectado "Compresor/Soportes")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia baja)
    (requiere-tecnico si)
    (justificacion "Desgaste normal - Requiere ajuste técnico")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Ajuste o reemplazo de soportes y piezas sueltas")
    (pasos "Técnico ajustará patas y soportes del compresor; reemplazará piezas desgastadas si es necesario")
    (tiempo-estimado 30)
    (costo-estimado 10000)))
  (printout t "DIAGNÓSTICO: Vibración por desgaste - Requiere revisión técnica" crlf)
)

; Regla 12: Heladera hace ruido - Sonido normal de funcionamiento
(defrule heladera-ruido-normal
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "hace ruido" ?desc) (str-index "ruido" ?desc) (str-index "vibra" ?desc)))
  (respuesta (caso-id ?id) (pregunta "tipo-ruido") (valor ?tipo))
  (test (or (eq ?tipo silbido) (eq ?tipo gorgoteo) (eq ?tipo burbujeo)))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Sonido normal de circulación del refrigerante")
    (probabilidad 100)
    (componente-afectado "Ninguno")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia baja)
    (requiere-tecnico no)
    (justificacion "Sonido normal - No requiere reparación")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Funcionamiento normal, sin acción requerida")
    (pasos "Se informa al cliente que el ruido percibido es normal del equipo")
    (tiempo-estimado 0)
    (costo-estimado 0)))
  (printout t "DIAGNÓSTICO: Ruido normal - No se requiere acción" crlf)
)

; Regla 13: Heladera hace ruido - Chirrido de ventilador
(defrule heladera-ruido-ventilador
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "hace ruido" ?desc) (str-index "ruido" ?desc) (str-index "vibra" ?desc)))
  (respuesta (caso-id ?id) (pregunta "tipo-ruido") (valor chirrido))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Ventilador desgastado o sin lubricación")
    (probabilidad 70)
    (componente-afectado "Ventilador")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia baja)
    (requiere-tecnico si)
    (justificacion "Ventilador desgastado - Reparación simple")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Lubricación o cambio de ventilador")
    (pasos "Técnico limpiará y lubricará el eje del ventilador; reemplazo si el ruido persiste")
    (tiempo-estimado 45)
    (costo-estimado 15000)))
  (printout t "DIAGNÓSTICO: Ventilador ruidoso - Requiere mantenimiento" crlf)
)

; Regla 14: Heladera hace ruido - Golpeteo periódico
(defrule heladera-ruido-golpeteo
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo heladera))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "hace ruido" ?desc) (str-index "ruido" ?desc) (str-index "vibra" ?desc)))
  (respuesta (caso-id ?id) (pregunta "tipo-ruido") (valor golpeteo))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Golpeteo por dilatación o soporte suelto"))
    (probabilidad 75)
    (componente-afectado "Compresor/Tuberías")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia baja)
    (requiere-tecnico si)
    (justificacion "Ruido de golpes - Ajuste simple")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Ajuste de soportes del compresor y aislación de tuberías")
    (pasos "Técnico ajustará soportes del motor y asegurará tuberías para reducir el ruido de golpes")
    (tiempo-estimado 30)
    (costo-estimado 5000)))
  (printout t "DIAGNÓSTICO: Golpeteo periódico - Requiere ajuste técnico" crlf)
)
