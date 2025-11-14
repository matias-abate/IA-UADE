package com.sistemaexperto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.sistemaexperto.model.enums.TipoSolucion;
import com.sistemaexperto.model.enums.Urgencia;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "diagnosticos")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Diagnostico {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String causaProbable;
    private Integer probabilidad; // 0-100
    private String componenteAfectado;
    private Boolean requiereTecnico;

    @Enumerated(EnumType.STRING)
    private TipoSolucion tipoSolucion;

    @Enumerated(EnumType.STRING)
    private Urgencia urgencia;

    private Double costoEstimadoMin;
    private Double costoEstimadoMax;
    private Integer tiempoEstimado; // en minutos

    @Builder.Default
    @ElementCollection
    @CollectionTable(name = "diagnostico_instrucciones_diy", joinColumns = @JoinColumn(name = "diagnostico_id"))
    @Column(name = "instruccion")
    private List<String> instruccionesDiy = new ArrayList<>();

    @Builder.Default
    @ElementCollection
    @CollectionTable(name = "diagnostico_alertas_seguridad", joinColumns = @JoinColumn(name = "diagnostico_id"))
    @Column(name = "alerta")
    private List<String> alertasSeguridad = new ArrayList<>();

    @Builder.Default
    @ElementCollection
    @CollectionTable(name = "diagnostico_repuestos", joinColumns = @JoinColumn(name = "diagnostico_id"))
    @Column(name = "repuesto")
    private List<String> repuestosProbables = new ArrayList<>();

    @Builder.Default
    @ElementCollection
    @CollectionTable(name = "diagnostico_mensajes_cliente", joinColumns = @JoinColumn(name = "diagnostico_id"))
    @Column(name = "mensaje")
    private List<String> mensajesCliente = new ArrayList<>();

    private Boolean generarOrdenTrabajo;
    private String prioridadOT;

    @PrePersist
    @PreUpdate
    private void ensureMutableLists() {
        // Convertir listas inmutables en mutables antes de persistir
        if (instruccionesDiy != null && !(instruccionesDiy instanceof ArrayList)) {
            instruccionesDiy = new ArrayList<>(instruccionesDiy);
        }
        if (alertasSeguridad != null && !(alertasSeguridad instanceof ArrayList)) {
            alertasSeguridad = new ArrayList<>(alertasSeguridad);
        }
        if (repuestosProbables != null && !(repuestosProbables instanceof ArrayList)) {
            repuestosProbables = new ArrayList<>(repuestosProbables);
        }
        if (mensajesCliente != null && !(mensajesCliente instanceof ArrayList)) {
            mensajesCliente = new ArrayList<>(mensajesCliente);
        }
    }
}

