package jar.restaurante.backend.repository;

import jar.restaurante.backend.entity.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CategoriaRepository extends JpaRepository<Categoria, Integer> {
    List<Categoria> findByActivoTrueOrderByNombreAsc();
}