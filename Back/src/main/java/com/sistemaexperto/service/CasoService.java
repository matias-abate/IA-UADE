package com.sistemaexperto.service;

import com.sistemaexperto.dto.CasoCreateDTO;
import com.sistemaexperto.dto.RespuestaDTO;
import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.model.enums.TipoElectrodomestico;
import com.sistemaexperto.model.Respuesta;
import com.sistemaexperto.repository.CasoRepository;
import com.sistemaexperto.repository.RespuestaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class CasoService {

    @Autowired
    private CasoRepository casoRepository;

    @Autowired
    private RespuestaRepository respuestaRepository;

    @Transactional
    public Caso crearCaso(Caso caso) {
        caso.setFechaCreacion(LocalDateTime.now());
        caso.setEstado(EstadoCaso.EN_DIAGNOSTICO);

        return casoRepository.save(caso);
    }

    @Transactional
    public Caso crearCaso(CasoCreateDTO dto) {
        Caso caso = new Caso();

        // Mapeo de datos del cliente
        caso.setClienteNombre(dto.getClienteNombre());
        caso.setClienteTelefono(dto.getClienteTelefono());

        // Mapeo de datos del electrodoméstico
        // Usar el campo 'tipo' si está presente, sino usar 'tipoElectrodomestico' por compatibilidad
        TipoElectrodomestico tipo = dto.getTipo() != null ? dto.getTipo() : dto.getTipoElectrodomestico();
        caso.setTipo(tipo);
        caso.setTipoElectrodomestico(tipo);

        caso.setMarca(dto.getMarca());
        caso.setModelo(dto.getModelo());
        caso.setAntiguedad(dto.getAntiguedad());

        // Mapeo del síntoma
        caso.setSintomaReportado(dto.getSintomaReportado());
        caso.setDescripcion(dto.getDescripcion() != null ? dto.getDescripcion() : dto.getSintomaReportado());

        // Datos iniciales
        caso.setFechaCreacion(LocalDateTime.now());
        caso.setEstado(EstadoCaso.EN_DIAGNOSTICO);

        return casoRepository.save(caso);
    }

    public Optional<Caso> findById(Long id) {
        return casoRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public Caso obtenerPorId(Long id) {
        return casoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Caso no encontrado con id: " + id));
    }

    public List<Caso> findAll() {
        return casoRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Caso> listarTodos() {
        return casoRepository.findAll();
    }

    @Transactional
    public void agregarRespuesta(Long casoId, RespuestaDTO dto) {
        Caso caso = casoRepository.findById(casoId)
            .orElseThrow(() -> new RuntimeException("Caso no encontrado"));

        Respuesta respuesta = new Respuesta();
        respuesta.setCaso(caso);
        respuesta.setPreguntaId(dto.getPreguntaId());
        respuesta.setValor(dto.getValor());

        caso.getRespuestas().add(respuesta);
        respuestaRepository.save(respuesta);
    }

    @Transactional
    public Caso save(Caso caso) {
        return casoRepository.save(caso);
    }

    @Transactional(readOnly = true)
    public List<Caso> findByFecha(LocalDate fecha) {
        LocalDateTime inicio = fecha.atStartOfDay();
        LocalDateTime fin = fecha.plusDays(1).atStartOfDay();
        return casoRepository.findByFechaCreacionBetween(inicio, fin);
    }
}

