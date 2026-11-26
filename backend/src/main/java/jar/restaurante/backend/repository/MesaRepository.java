package jar.restaurante.backend.repository;

import jar.restaurante.backend.entity.EstadoMesa;
import jar.restaurante.backend.entity.Mesa;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MesaRepository extends JpaRepository<Mesa, Integer> {
    List<Mesa> findAllByOrderByNumeroAsc();
    List<Mesa> findByEstadoOrderByNumeroAsc(EstadoMesa estado);
}