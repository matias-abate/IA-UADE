package com.sistemaexperto.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "hipotesis")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Hipotesis {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String descripcion;
    private Integer probabilidad;
    private boolean activa;

    @ManyToOne
    @JoinColumn(name = "caso_id")
    private Caso caso;
}

