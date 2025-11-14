; ============================================
; CASOS DE PRUEBA - SISTEMA EXPERTO
; ============================================
; Este archivo contiene casos de prueba para validar las reglas CLIPS

(deffacts casos-prueba
  ; CASO 1: Heladera no enfría - Compresor
  (caso (id 1) (fecha "2025-11-01") (cliente "María González")
        (telefono "11-5555-1234") (direccion "Av. Libertador 1234") 
        (estado en-diagnostico))
  (electrodomestico (tipo heladera) (marca "Samsung") (modelo "RT38K")
                    (antiguedad 5) (en-garantia no))
  (sintoma (caso-id 1) (descripcion "no enfria") (gravedad alta))
  (respuesta (caso-id 1) (pregunta "1") (valor si))
  (respuesta (caso-id 1) (pregunta "2") (valor no))
  (respuesta (caso-id 1) (pregunta "3") (valor si))
  
  ; CASO 2: Lavarropas no desagota - Filtro
  (caso (id 2) (fecha "2025-11-01") (cliente "Juan Pérez")
        (telefono "11-5555-5678") (direccion "Cabildo 2345") 
        (estado en-diagnostico))
  (electrodomestico (tipo lavarropas) (marca "Drean") (modelo "Next 8.12")
                    (antiguedad 3) (en-garantia no))
  (sintoma (caso-id 2) (descripcion "no desagota") (gravedad alta))
  (respuesta (caso-id 2) (pregunta "lava-normalmente") (valor si))
  
  ; CASO 3: Microondas hace chispas - CRÍTICO
  (caso (id 3) (fecha "2025-11-01") (cliente "Ana Martínez")
        (telefono "11-5555-9012") (direccion "Santa Fe 3456") 
        (estado en-diagnostico))
  (electrodomestico (tipo microondas) (marca "LG") (modelo "MS2535")
                    (antiguedad 4) (en-garantia no))
  (sintoma (caso-id 3) (descripcion "hace chispas") (gravedad critica))
  (respuesta (caso-id 3) (pregunta "objetos-metalicos-dentro") (valor no))
  
  ; CASO 4: Heladera pierde agua - Desagüe (DIY)
  (caso (id 4) (fecha "2025-11-01") (cliente "Carlos Rodríguez")
        (telefono "11-5555-3456") (direccion "Córdoba 4567") 
        (estado en-diagnostico))
  (electrodomestico (tipo heladera) (marca "Whirlpool") (modelo "WRF540CWHZ")
                    (antiguedad 2) (en-garantia no))
  (sintoma (caso-id 4) (descripcion "pierde agua") (gravedad media))
  (respuesta (caso-id 4) (pregunta "agua-ubicacion") (valor interior))
  (respuesta (caso-id 4) (pregunta "hielo-excesivo") (valor no))
)

