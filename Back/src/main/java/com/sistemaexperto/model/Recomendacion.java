package com.sistemaexperto.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "recomendaciones")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recomendacion {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "caso_id")
    private Caso caso;
    
    @Enumerated(EnumType.STRING)
    private TipoRecomendacion tipo;
    
    private String mensaje;
    
    public enum TipoRecomendacion {
        PREVENCION,
        ECONOMICA,
        SEGURIDAD
    }
}

