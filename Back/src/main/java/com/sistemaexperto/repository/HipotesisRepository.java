package com.sistemaexperto.repository;

import com.sistemaexperto.model.Hipotesis;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HipotesisRepository extends JpaRepository<Hipotesis, Long> {
    List<Hipotesis> findByCasoIdAndActivaTrue(Long casoId);
    List<Hipotesis> findByCasoId(Long casoId);
}

