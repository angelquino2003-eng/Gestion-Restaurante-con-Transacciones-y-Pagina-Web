package jar.restaurante.backend.controller;

import jakarta.persistence.EntityManager;
import jar.restaurante.backend.dto.CambioEstadoVentaRequestDTO;
import jar.restaurante.backend.dto.DetalleVentaRequestDTO;
import jar.restaurante.backend.dto.DetalleVentaResponseDTO;
import jar.restaurante.backend.dto.VentaRequestDTO;
import jar.restaurante.backend.dto.VentaResponseDTO;
import jar.restaurante.backend.entity.Combo;
import jar.restaurante.backend.entity.DetalleVenta;
import jar.restaurante.backend.entity.Mesa;
import jar.restaurante.backend.entity.Producto;
import jar.restaurante.backend.entity.Venta;
import jar.restaurante.backend.repository.ComboRepository;
import jar.restaurante.backend.repository.MesaRepository;
import jar.restaurante.backend.repository.ProductoRepository;
import jar.restaurante.backend.repository.VentaRepository;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/ventas")
public class VentaController {

    private static final Set<String> ESTADOS_VALIDOS = Set.of(
            "pendiente_pago",
            "pendiente",
            "en_proceso",
            "listo",
            "entregado",
            "finalizada",
            "cancelado",
            "perdida"
    );

    private final VentaRepository ventaRepository;
    private final MesaRepository mesaRepository;
    private final ProductoRepository productoRepository;
    private final ComboRepository comboRepository;
    private final EntityManager entityManager;

    public VentaController(
            VentaRepository ventaRepository,
            MesaRepository mesaRepository,
            ProductoRepository productoRepository,
            ComboRepository comboRepository,
            EntityManager entityManager) {
        this.ventaRepository = ventaRepository;
        this.mesaRepository = mesaRepository;
        this.productoRepository = productoRepository;
        this.comboRepository = comboRepository;
        this.entityManager = entityManager;
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

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Transactional
    public VentaResponseDTO crearVenta(@RequestBody VentaRequestDTO request) {
        if (request == null || request.getDetalles() == null || request.getDetalles().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La venta debe contener al menos un detalle");
        }

        String tipoVenta = (request.getTipoVenta() == null || request.getTipoVenta().isBlank())
                ? "presencial"
                : request.getTipoVenta().trim().toLowerCase();

        if (!"presencial".equals(tipoVenta) && !"delivery".equals(tipoVenta)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "tipoVenta debe ser 'presencial' o 'delivery'");
        }

        BigDecimal descuento = request.getDescuento() != null ? request.getDescuento() : BigDecimal.ZERO;
        if (descuento.compareTo(BigDecimal.ZERO) < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El descuento no puede ser negativo");
        }
        if (descuento.compareTo(BigDecimal.ZERO) > 0
                && (request.getMotivoDescuento() == null || request.getMotivoDescuento().isBlank())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "motivoDescuento es obligatorio cuando descuento es mayor a 0");
        }

        Venta venta = new Venta();
        venta.setTipoVenta(tipoVenta);

        String estadoInicial = (request.getEstado() == null || request.getEstado().isBlank())
                ? "pendiente"
                : request.getEstado().trim();
        if ("cancelado".equalsIgnoreCase(estadoInicial)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "No se puede crear una venta directamente en estado 'cancelado'");
        }
        venta.setEstado(estadoInicial);

        if ("presencial".equals(tipoVenta)) {
            if (request.getIdMesa() == null || request.getIdEmpleado() == null || request.getIdCaja() == null) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Una venta 'presencial' requiere idMesa, idEmpleado e idCaja");
            }

            Mesa mesa = mesaRepository.findById(request.getIdMesa())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Mesa no encontrada: " + request.getIdMesa()));
            validarExisteRegistro("empleado", "id_empleado", request.getIdEmpleado(), "Empleado no encontrado");
            validarExisteRegistro("caja", "id_caja", request.getIdCaja(), "Caja no encontrada");

            venta.setMesa(mesa);
            venta.setIdEmpleado(request.getIdEmpleado());
            venta.setIdCaja(request.getIdCaja());
            venta.setCostoDelivery(BigDecimal.ZERO);
        } else {
            if (request.getIdCliente() == null) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "Una venta 'delivery' requiere idCliente");
            }
            if (request.getIdMesa() != null) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "Una venta 'delivery' no debe incluir idMesa");
            }

            validarExisteRegistro("cliente", "id_cliente", request.getIdCliente(), "Cliente no encontrado");

            BigDecimal costoDelivery = request.getCostoDelivery() != null
                    ? request.getCostoDelivery()
                    : BigDecimal.ZERO;
            if (costoDelivery.compareTo(BigDecimal.ZERO) < 0) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "costoDelivery no puede ser negativo");
            }

            venta.setIdCliente(request.getIdCliente());
            venta.setCostoDelivery(costoDelivery);
        }

        BigDecimal subtotalCalculado = BigDecimal.ZERO;
        for (DetalleVentaRequestDTO detReq : request.getDetalles()) {
            if (detReq.getCantidad() == null || detReq.getCantidad() <= 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La cantidad debe ser mayor a 0");
            }
            if (detReq.getPrecioUnitario() == null || detReq.getPrecioUnitario().compareTo(BigDecimal.ZERO) < 0) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "El precio unitario no puede ser nulo ni negativo");
            }

            boolean tieneProducto = detReq.getIdProducto() != null;
            boolean tieneCombo = detReq.getIdCombo() != null;
            if (tieneProducto == tieneCombo) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Cada detalle debe especificar exactamente idProducto o idCombo");
            }

            BigDecimal linea = detReq.getPrecioUnitario().multiply(BigDecimal.valueOf(detReq.getCantidad()));
            subtotalCalculado = subtotalCalculado.add(linea);

            DetalleVenta detalle = new DetalleVenta();
            detalle.setCantidad(detReq.getCantidad());
            detalle.setPrecioUnitario(detReq.getPrecioUnitario());

            if (tieneProducto) {
                Producto producto = productoRepository.findById(detReq.getIdProducto())
                        .orElseThrow(() -> new ResponseStatusException(
                                HttpStatus.NOT_FOUND, "Producto no encontrado: " + detReq.getIdProducto()));
                detalle.setProducto(producto);
            } else {
                Combo combo = comboRepository.findById(detReq.getIdCombo())
                        .orElseThrow(() -> new ResponseStatusException(
                                HttpStatus.NOT_FOUND, "Combo no encontrado: " + detReq.getIdCombo()));
                detalle.setCombo(combo);
            }

            venta.agregarDetalle(detalle);
        }

        if (descuento.compareTo(subtotalCalculado) > 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "El descuento no puede ser mayor al monto de los ítems");
        }

        venta.setDescuento(descuento);
        venta.setMotivoDescuento(request.getMotivoDescuento());

        Venta guardada = ventaRepository.saveAndFlush(venta);
        entityManager.refresh(guardada);
        for (DetalleVenta det : guardada.getDetalles()) {
            entityManager.refresh(det);
        }

        return toResponseDTO(guardada);
    }

    @PatchMapping("/{id}/estado")
    @Transactional
    public VentaResponseDTO cambiarEstadoVenta(
            @PathVariable Integer id,
            @RequestBody CambioEstadoVentaRequestDTO request) {
        if (request == null || request.getEstado() == null || request.getEstado().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El campo estado es obligatorio");
        }

        String nuevoEstado = request.getEstado().trim().toLowerCase();
        if (!ESTADOS_VALIDOS.contains(nuevoEstado)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Estado de venta no válido: " + nuevoEstado);
        }

        Venta venta = ventaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Venta no encontrada: " + id));

        String estadoActual = venta.getEstado() != null
                ? venta.getEstado().trim().toLowerCase()
                : "";
        if ("finalizada".equals(estadoActual) || "cancelado".equals(estadoActual)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "No se puede cambiar el estado de una venta ya '" + estadoActual + "'");
        }

        String motivoCancelacion = request.getMotivoCancelacion() != null
                ? request.getMotivoCancelacion().trim()
                : null;

        if ("cancelado".equals(nuevoEstado)) {
            if (motivoCancelacion == null || motivoCancelacion.isBlank()) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "motivoCancelacion es obligatorio cuando el estado cambia a 'cancelado'");
            }
            venta.setMotivoCancelacion(motivoCancelacion);
        } else if (motivoCancelacion != null && !motivoCancelacion.isBlank()) {
            venta.setMotivoCancelacion(motivoCancelacion);
        }

        venta.setEstado(nuevoEstado);

        Venta actualizada = ventaRepository.saveAndFlush(venta);
        entityManager.refresh(actualizada);
        for (DetalleVenta det : actualizada.getDetalles()) {
            entityManager.refresh(det);
        }

        return toResponseDTO(actualizada);
    }

    private void validarExisteRegistro(String tabla, String columnaId, Integer id, String mensajeNotFound) {
        Number count = (Number) entityManager
                .createNativeQuery("SELECT COUNT(*) FROM " + tabla + " WHERE " + columnaId + " = :id")
                .setParameter("id", id)
                .getSingleResult();
        if (count == null || count.longValue() == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, mensajeNotFound + ": " + id);
        }
    }

    private VentaResponseDTO toResponseDTO(Venta venta) {
        VentaResponseDTO dto = new VentaResponseDTO();
        dto.setIdVenta(venta.getIdVenta());
        dto.setTipoVenta(venta.getTipoVenta());
        dto.setIdMesa(venta.getMesa() != null ? venta.getMesa().getIdMesa() : null);
        dto.setIdCliente(venta.getIdCliente());
        dto.setIdEmpleado(venta.getIdEmpleado());
        dto.setIdCaja(venta.getIdCaja());
        dto.setFechaCreacion(venta.getFechaCreacion());
        dto.setEstado(venta.getEstado());
        dto.setMontoItems(venta.getMontoItems());
        dto.setDescuento(venta.getDescuento());
        dto.setMotivoDescuento(venta.getMotivoDescuento());
        dto.setCostoDelivery(venta.getCostoDelivery());
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