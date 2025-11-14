package com.sistemaexperto.dto;

import com.sistemaexperto.model.enums.TipoElectrodomestico;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CasoDTO {
    private String clienteNombre;
    private String clienteTelefono;
    private TipoElectrodomestico tipo;
    private String marca;
    private String modelo;
    private Integer antiguedad;
    private String sintomaReportado;
}
