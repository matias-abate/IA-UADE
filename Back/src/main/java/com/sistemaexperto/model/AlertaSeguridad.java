package com.sistemaexperto.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "alertas_seguridad")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AlertaSeguridad {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "caso_id")
    private Caso caso;
    
    @Enumerated(EnumType.STRING)
    private TipoAlerta tipo;
    
    private String mensaje;
    
    public enum TipoAlerta {
        RIESGO_ELECTRICO,
        RIESGO_GAS,
        RIESGO_INCENDIO
    }
}

