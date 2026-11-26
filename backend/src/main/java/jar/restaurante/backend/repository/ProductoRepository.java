package jar.restaurante.backend.repository;

import jar.restaurante.backend.entity.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface ProductoRepository extends JpaRepository<Producto, Integer> {

    @Query("SELECT p FROM Producto p JOIN FETCH p.categoria WHERE p.activo = true ORDER BY p.nombre ASC")
    List<Producto> findActivosConCategoria();

    @Query("SELECT p FROM Producto p JOIN FETCH p.categoria WHERE p.activo = true AND p.categoria.idCategoria = :idCategoria ORDER BY p.nombre ASC")
    List<Producto> findActivosPorCategoria(@Param("idCategoria") Integer idCategoria);
}