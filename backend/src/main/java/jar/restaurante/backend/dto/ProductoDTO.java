package jar.restaurante.backend.dto;

import jar.restaurante.backend.entity.Producto;
import java.math.BigDecimal;

public record ProductoDTO(
        Integer idProducto,
        String nombre,
        String descripcion,
        BigDecimal precio,
        Boolean activo,
        Integer idCategoria,
        String nombreCategoria
) {
    public static ProductoDTO fromEntity(Producto p) {
        return new ProductoDTO(
                p.getIdProducto(),
                p.getNombre(),
                p.getDescripcion(),
                p.getPrecio(),
                p.getActivo(),
                p.getCategoria().getIdCategoria(),
                p.getCategoria().getNombre()
        );
    }
}