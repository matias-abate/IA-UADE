package com.sistemaexperto.dto;

import lombok.Data;
import com.sistemaexperto.model.enums.TipoElectrodomestico;

@Data
public class CasoCreateDTO {
    private String clienteNombre;
    private String clienteTelefono;
    private TipoElectrodomestico tipo;
    private String marca;
    private String modelo;
    private Integer antiguedad;
    private String sintomaReportado;

    // Mantenemos estos para compatibilidad
    private String descripcion;
    private TipoElectrodomestico tipoElectrodomestico;
}

