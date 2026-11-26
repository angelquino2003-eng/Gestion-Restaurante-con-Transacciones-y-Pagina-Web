package jar.restaurante.backend.dto;

import jar.restaurante.backend.entity.Combo;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record ComboDTO(
        Integer idCombo,
        String nombre,
        String descripcion,
        BigDecimal precio,
        LocalDate vigenteDesde,
        LocalDate vigenteHasta,
        Boolean activo,
        List<ComboItemDTO> productos
) {
    public static ComboDTO fromEntity(Combo c) {
        List<ComboItemDTO> lista = c.getItems()
                .stream()
                .map(ComboItemDTO::fromEntity)
                .toList();
        return new ComboDTO(
                c.getIdCombo(),
                c.getNombre(),
                c.getDescripcion(),
                c.getPrecio(),
                c.getVigenteDesde(),
                c.getVigenteHasta(),
                c.getActivo(),
                lista
        );
    }
}