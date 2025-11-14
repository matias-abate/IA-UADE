package com.sistemaexperto.config;

import com.sistemaexperto.model.Caso;
import com.sistemaexperto.model.enums.EstadoCaso;
import com.sistemaexperto.model.enums.TipoElectrodomestico;
import com.sistemaexperto.repository.CasoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer {

    @Bean
    public CommandLineRunner initData(CasoRepository casoRepository) {
        return args -> {
            log.info("=== Inicializando Base de Datos ===");

            // Verificar si ya hay datos
            long count = casoRepository.count();
            log.info("Casos existentes en BD: {}", count);

            if (count == 0) {
                log.info("Creando casos de ejemplo...");

                // Caso 1: Heladera
                Caso caso1 = new Caso();
                caso1.setDescripcion("Heladera no enfría correctamente");
                caso1.setClienteNombre("Juan Pérez");
                caso1.setClienteTelefono("1234567890");
                caso1.setTipo(TipoElectrodomestico.HELADERA);
                caso1.setTipoElectrodomestico(TipoElectrodomestico.HELADERA);
                caso1.setMarca("Samsung");
                caso1.setModelo("RT38K5932SL");
                caso1.setAntiguedad(3);
                caso1.setSintomaReportado("La heladera no mantiene la temperatura");
                caso1.setEstado(EstadoCaso.EN_DIAGNOSTICO);
                caso1.setFechaCreacion(LocalDateTime.now());
                casoRepository.save(caso1);
                log.info("Caso 1 creado: {}", caso1.getId());

                // Caso 2: Lavarropas
                Caso caso2 = new Caso();
                caso2.setDescripcion("Lavarropas no enciende");
                caso2.setClienteNombre("María García");
                caso2.setClienteTelefono("0987654321");
                caso2.setTipo(TipoElectrodomestico.LAVARROPAS);
                caso2.setTipoElectrodomestico(TipoElectrodomestico.LAVARROPAS);
                caso2.setMarca("LG");
                caso2.setModelo("WM3488HW");
                caso2.setAntiguedad(5);
                caso2.setSintomaReportado("No responde al presionar el botón de encendido");
                caso2.setEstado(EstadoCaso.EN_DIAGNOSTICO);
                caso2.setFechaCreacion(LocalDateTime.now());
                casoRepository.save(caso2);
                log.info("Caso 2 creado: {}", caso2.getId());

                // Caso 3: Microondas
                Caso caso3 = new Caso();
                caso3.setDescripcion("Microondas no calienta");
                caso3.setClienteNombre("Carlos López");
                caso3.setClienteTelefono("1122334455");
                caso3.setTipo(TipoElectrodomestico.MICROONDAS);
                caso3.setTipoElectrodomestico(TipoElectrodomestico.MICROONDAS);
                caso3.setMarca("Whirlpool");
                caso3.setModelo("WM1404W");
                caso3.setAntiguedad(2);
                caso3.setSintomaReportado("Funciona pero no calienta la comida");
                caso3.setEstado(EstadoCaso.EN_DIAGNOSTICO);
                caso3.setFechaCreacion(LocalDateTime.now());
                casoRepository.save(caso3);
                log.info("Caso 3 creado: {}", caso3.getId());

                log.info("=== {} casos de ejemplo creados exitosamente ===", casoRepository.count());
            } else {
                log.info("La base de datos ya contiene datos. No se crearán casos de ejemplo.");
            }

            log.info("=== Inicialización completada ===");
        };
    }
}

