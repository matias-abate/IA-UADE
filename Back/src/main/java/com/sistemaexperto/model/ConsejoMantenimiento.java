package com.sistemaexperto.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "consejos_mantenimiento")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConsejoMantenimiento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "caso_id")
    private Caso caso;
    
    private String periodicidad;
    
    @Column(length = 2000)
    private String acciones;
}

