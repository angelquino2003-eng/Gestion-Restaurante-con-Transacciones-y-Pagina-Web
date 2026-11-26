package jar.restaurante.backend.repository;

import jar.restaurante.backend.entity.Venta;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface VentaRepository extends JpaRepository<Venta, Integer> {

    @Query("SELECT DISTINCT v FROM Venta v LEFT JOIN FETCH v.detalles ORDER BY v.idVenta DESC")
    List<Venta> findAllWithDetalles();
}