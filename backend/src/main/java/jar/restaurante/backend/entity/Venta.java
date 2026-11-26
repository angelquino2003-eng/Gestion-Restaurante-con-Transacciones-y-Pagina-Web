package jar.restaurante.backend.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Entity
@Table(name = "venta")
public class Venta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_venta")
    private Integer idVenta;

    @Column(name = "tipo_venta", nullable = false, length = 20)
    private String tipoVenta;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_mesa")
    private Mesa mesa;

    @Column(name = "id_cliente")
    private Integer idCliente;

    @Column(name = "id_empleado")
    private Integer idEmpleado;

    @Column(name = "id_caja")
    private Integer idCaja;

    @Column(name = "fecha_venta", insertable = false, updatable = false)
    private LocalDateTime fechaCreacion;

    @Column(name = "estado", nullable = false, length = 30)
    private String estado;

    @Column(name = "descuento", nullable = false, precision = 10, scale = 2)
    private BigDecimal descuento;

    @Column(name = "motivo_descuento", length = 100)
    private String motivoDescuento;

    @Column(name = "costo_delivery", nullable = false, precision = 10, scale = 2)
    private BigDecimal costoDelivery;

    // Mantenido por trigger o calculado en BD: no forzar manualmente en INSERT/UPDATE
    @Column(name = "monto_items", insertable = false, updatable = false, precision = 10, scale = 2)
    private BigDecimal montoItems;

    // Columnas generadas STORED en MySQL
    @Column(name = "base_imponible", insertable = false, updatable = false, precision = 10, scale = 2)
    private BigDecimal baseImponible;

    @Column(name = "igv", insertable = false, updatable = false, precision = 10, scale = 2)
    private BigDecimal igv;

    @Column(name = "total", insertable = false, updatable = false, precision = 10, scale = 2)
    private BigDecimal total;

    @Column(name = "motivo_cancelacion", length = 150)
    private String motivoCancelacion;

    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<DetalleVenta> detalles = new ArrayList<>();

    public Venta() {
    }

    public Integer getIdVenta() {
        return idVenta;
    }

    public void setIdVenta(Integer idVenta) {
        this.idVenta = idVenta;
    }

    public String getTipoVenta() {
        return tipoVenta;
    }

    public void setTipoVenta(String tipoVenta) {
        this.tipoVenta = tipoVenta;
    }

    public Mesa getMesa() {
        return mesa;
    }

    public void setMesa(Mesa mesa) {
        this.mesa = mesa;
    }

    public Integer getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(Integer idCliente) {
        this.idCliente = idCliente;
    }

    public Integer getIdEmpleado() {
        return idEmpleado;
    }

    public void setIdEmpleado(Integer idEmpleado) {
        this.idEmpleado = idEmpleado;
    }

    public Integer getIdCaja() {
        return idCaja;
    }

    public void setIdCaja(Integer idCaja) {
        this.idCaja = idCaja;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public BigDecimal getDescuento() {
        return descuento;
    }

    public void setDescuento(BigDecimal descuento) {
        this.descuento = descuento;
    }

    public String getMotivoDescuento() {
        return motivoDescuento;
    }

    public void setMotivoDescuento(String motivoDescuento) {
        this.motivoDescuento = motivoDescuento;
    }

    public BigDecimal getCostoDelivery() {
        return costoDelivery;
    }

    public void setCostoDelivery(BigDecimal costoDelivery) {
        this.costoDelivery = costoDelivery;
    }

    public BigDecimal getMontoItems() {
        return montoItems;
    }

    public BigDecimal getBaseImponible() {
        return baseImponible;
    }

    public BigDecimal getIgv() {
        return igv;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public List<DetalleVenta> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<DetalleVenta> detalles) {
        this.detalles = detalles;
    }

    public void agregarDetalle(DetalleVenta detalle) {
        detalles.add(detalle);
        detalle.setVenta(this);
    }

    public String getMotivoCancelacion() {
    return motivoCancelacion;
    }

    public void setMotivoCancelacion(String motivoCancelacion) {
    this.motivoCancelacion = motivoCancelacion;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Venta other)) return false;
        return idVenta != null && Objects.equals(idVenta, other.idVenta);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}