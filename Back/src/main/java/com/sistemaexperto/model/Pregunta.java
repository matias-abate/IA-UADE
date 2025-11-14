package com.sistemaexperto.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Pregunta {
    private Long id;
    private String texto;
    private TipoPregunta tipo;
    private List<String> opciones;
    private boolean critica;
    private String ayuda;
    private String imagenReferencia;

    public enum TipoPregunta {
        SI_NO,
        OPCION_MULTIPLE,
        TEXTO
    }
}

