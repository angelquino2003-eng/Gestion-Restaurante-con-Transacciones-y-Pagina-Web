package jar.restaurante.backend.dto;

import jar.restaurante.backend.entity.ComboProducto;

public record ComboItemDTO(
        Integer idProducto,
        String nombreProducto,
        Integer cantidad
) {
    public static ComboItemDTO fromEntity(ComboProducto cp) {
        return new ComboItemDTO(
                cp.getProducto().getIdProducto(),
                cp.getProducto().getNombre(),
                cp.getCantidad()
        );
    }
}