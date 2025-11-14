package com.sistemaexperto.repository;

import com.sistemaexperto.model.Caso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CasoRepository extends JpaRepository<Caso, Long> {
    
    @Query("SELECT c FROM Caso c WHERE c.fechaCreacion >= :inicio AND c.fechaCreacion < :fin")
    List<Caso> findByFechaCreacionBetween(@Param("inicio") LocalDateTime inicio, @Param("fin") LocalDateTime fin);
}