package com.sistemaexperto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.model.enums.TipoElectrodomestico;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "casos")
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Caso {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String descripcion;
    private String clienteNombre;
    private String clienteTelefono;
    
    @Enumerated(EnumType.STRING)
    private TipoElectrodomestico tipo;
    
    @Enumerated(EnumType.STRING)
    private TipoElectrodomestico tipoElectrodomestico;

    private String marca;
    private String modelo;
    private Integer antiguedad;
    private String sintomaReportado;
    
    @Enumerated(EnumType.STRING)
    private EstadoCaso estado;
    
    @CreationTimestamp
    private LocalDateTime fechaCreacion;
    
    @OneToMany(mappedBy = "caso", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Respuesta> respuestas = new ArrayList<>();

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JoinColumn(name = "caso_id")
    private List<Hipotesis> hipotesis = new ArrayList<>();

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JoinColumn(name = "diagnostico_id")
    private Diagnostico diagnostico;
}
