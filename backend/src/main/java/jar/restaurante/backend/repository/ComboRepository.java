package jar.restaurante.backend.repository;

import jar.restaurante.backend.entity.Combo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface ComboRepository extends JpaRepository<Combo, Integer> {

    @Query("SELECT DISTINCT c FROM Combo c LEFT JOIN FETCH c.items cp LEFT JOIN FETCH cp.producto WHERE c.activo = true ORDER BY c.nombre ASC")
    List<Combo> findActivosConProductos();
}