; ============================================
; REGLAS DE DIAGNÓSTICO - MICROONDAS
; ============================================

; Regla 11: Microondas no calienta - Magnetrón defectuoso
(defrule microondas-no-calienta-magnetron
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo microondas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no calienta" ?desc) (str-index "no calienta" ?desc) (str-index "frío" ?desc)))
  (respuesta (caso-id ?id) (pregunta "luz-interior-funciona") (valor si))
  (respuesta (caso-id ?id) (pregunta "plato-gira") (valor si))
  (respuesta (caso-id ?id) (pregunta "ventilador-funciona") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Magnetrón defectuoso")
    (probabilidad 80)
    (componente-afectado "Magnetrón")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-complejo)
    (urgencia media)
    (requiere-tecnico si)
    (justificacion "Magnetrón - Reparación costosa, evaluar vs reemplazo")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Evaluación magnetrón - Posible reemplazo equipo")
    (pasos "Técnico verificará magnetrón. IMPORTANTE: Si tiene más de 5-7 años, probablemente convenga más comprar nuevo que reparar (magnetrón cuesta $40-60k + mano de obra)")
    (tiempo-estimado 90)
    (costo-estimado 55000)))
  (printout t "DIAGNÓSTICO: Magnetrón - Evaluar costo/beneficio reparación vs compra" crlf)
)

; Regla 12: Microondas hace chispas - CRÍTICO
(defrule microondas-chispas-critico
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo microondas))
  (sintoma (caso-id ?id) (descripcion ?desc) (gravedad ?grav))
  (test (or (str-index "chispas" ?desc) (str-index "chispa" ?desc) (eq ?grav critica)))
  (respuesta (caso-id ?id) (pregunta "objetos-metalicos-dentro") (valor no))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Mica interna quemada o pintura interior dañada")
    (probabilidad 85)
    (componente-afectado "Mica/Recubrimiento interno")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia critica)
    (requiere-tecnico si)
    (justificacion "RIESGO DE INCENDIO - Uso debe detenerse inmediatamente")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "¡DETENER USO INMEDIATO! - Reemplazo de mica")
    (pasos "⚠ PELIGRO: No usar hasta reparación. Técnico reemplazará mica (placa protectora interna). Reparación simple y económica, pero URGENTE.")
    (tiempo-estimado 30)
    (costo-estimado 8000)))
  (printout t "⚠⚠⚠ ALERTA CRÍTICA: DETENER USO INMEDIATO - RIESGO INCENDIO" crlf)
)

; Regla 13: Microondas plato no gira - Acople roto (DIY)
(defrule microondas-plato-no-gira
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo microondas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "plato no gira" ?desc) (str-index "plato" ?desc)))
  (respuesta (caso-id ?id) (pregunta "calienta-normalmente") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Acople del plato roto o desplazado")
    (probabilidad 90)
    (componente-afectado "Acople plato giratorio")))
  (assert (decision
    (caso-id ?id)
    (tipo diy)
    (urgencia baja)
    (requiere-tecnico no)
    (justificacion "Repuesto muy económico - Cliente puede verificar y reemplazar")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Verificación/reemplazo de acople")
    (pasos "1. Sacar plato de vidrio | 2. Retirar aro con rueditas | 3. Verificar acople (pieza plástica con 3 puntas en el centro) | 4. Si está roto/partido, comprar repuesto ($500-1000 marca genérica, $1500-3000 original) | 5. Instalar nuevo acople | 6. Colocar aro y plato | NOTA: El microondas funciona sin plato giratorio, solo cocina desparejo")
    (tiempo-estimado 10)
    (costo-estimado 1500)))
)

; Regla 14: Microondas no enciende - Fusible
(defrule microondas-no-enciende
  (caso (id ?id) (estado en-diagnostico))
  (electrodomestico (tipo microondas))
  (sintoma (caso-id ?id) (descripcion ?desc))
  (test (or (str-index "no enciende" ?desc) (str-index "no prende" ?desc) (str-index "no funciona" ?desc)))
  (respuesta (caso-id ?id) (pregunta "enchufado-correctamente") (valor si))
  (respuesta (caso-id ?id) (pregunta "otras-cosas-funcionan-mismo-enchufe") (valor si))
  =>
  (assert (diagnostico
    (caso-id ?id)
    (causa-probable "Fusible interno quemado o interruptor de puerta defectuoso")
    (probabilidad 75)
    (componente-afectado "Fusible/Interruptor puerta")))
  (assert (decision
    (caso-id ?id)
    (tipo tecnico-simple)
    (urgencia media)
    (requiere-tecnico si)
    (justificacion "Requiere apertura del equipo - Riesgo eléctrico")))
  (assert (solucion
    (caso-id ?id)
    (descripcion "Verificación fusible y interruptor puerta")
    (pasos "Técnico verificará: 1. Fusible cerámico interno (falla común) | 2. Interruptores de seguridad de puerta (3 unidades) | Reparación económica")
    (tiempo-estimado 45)
    (costo-estimado 12000)))
)

