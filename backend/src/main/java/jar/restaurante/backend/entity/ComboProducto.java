package jar.restaurante.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "combo_producto")
public class ComboProducto {

    @EmbeddedId
    private ComboProductoId id = new ComboProductoId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idCombo")
    @JoinColumn(name = "id_combo", nullable = false)
    private Combo combo;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idProducto")
    @JoinColumn(name = "id_producto", nullable = false)
    private Producto producto;

    @Column(name = "cantidad", nullable = false)
    private Integer cantidad = 1;

    public ComboProducto() {
    }

    public ComboProductoId getId() {
        return id;
    }

    public void setId(ComboProductoId id) {
        this.id = id;
    }

    public Combo getCombo() {
        return combo;
    }

    public void setCombo(Combo combo) {
        this.combo = combo;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }
}