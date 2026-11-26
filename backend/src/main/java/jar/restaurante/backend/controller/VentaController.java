package jar.restaurante.backend.controller;

import jar.restaurante.backend.dto.DetalleVentaResponseDTO;
import jar.restaurante.backend.dto.VentaResponseDTO;
import jar.restaurante.backend.entity.DetalleVenta;
import jar.restaurante.backend.entity.Venta;
import jar.restaurante.backend.repository.VentaRepository;
import java.util.ArrayList;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/ventas")
public class VentaController {

    private final VentaRepository ventaRepository;

    public VentaController(VentaRepository ventaRepository) {
        this.ventaRepository = ventaRepository;
    }

    @GetMapping
    @Transactional(readOnly = true)
    public List<VentaResponseDTO> listarVentas() {
        List<Venta> ventas = ventaRepository.findAllWithDetalles();
        List<VentaResponseDTO> resultado = new ArrayList<>();
        for (Venta venta : ventas) {
            resultado.add(toResponseDTO(venta));
        }
        return resultado;
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public VentaResponseDTO obtenerVentaPorId(@PathVariable Integer id) {
        Venta venta = ventaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Venta no encontrada: " + id));
        return toResponseDTO(venta);
    }

    private VentaResponseDTO toResponseDTO(Venta venta) {
        VentaResponseDTO dto = new VentaResponseDTO();
        dto.setIdVenta(venta.getIdVenta());
        dto.setIdMesa(venta.getMesa() != null ? venta.getMesa().getIdMesa() : null);
        dto.setFechaCreacion(venta.getFechaCreacion());
        dto.setEstado(venta.getEstado());
        dto.setMontoItems(venta.getMontoItems());
        dto.setBaseImponible(venta.getBaseImponible());
        dto.setIgv(venta.getIgv());
        dto.setTotal(venta.getTotal());

        List<DetalleVentaResponseDTO> detallesDto = new ArrayList<>();
        for (DetalleVenta detalle : venta.getDetalles()) {
            DetalleVentaResponseDTO detDto = new DetalleVentaResponseDTO();
            detDto.setIdDetalle(detalle.getIdDetalleVenta());
            detDto.setIdProducto(detalle.getProducto() != null ? detalle.getProducto().getIdProducto() : null);
            detDto.setIdCombo(detalle.getCombo() != null ? detalle.getCombo().getIdCombo() : null);
            detDto.setCantidad(detalle.getCantidad());
            detDto.setPrecioUnitario(detalle.getPrecioUnitario());
            detDto.setSubtotal(detalle.getSubtotal());
            detallesDto.add(detDto);
        }
        dto.setDetalles(detallesDto);
        return dto;
    }
}