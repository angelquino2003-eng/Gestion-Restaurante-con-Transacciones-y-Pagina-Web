package jar.restaurante.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class ComboProductoId implements Serializable {

    @Column(name = "id_combo")
    private Integer idCombo;

    @Column(name = "id_producto")
    private Integer idProducto;

    public ComboProductoId() {
    }

    public ComboProductoId(Integer idCombo, Integer idProducto) {
        this.idCombo = idCombo;
        this.idProducto = idProducto;
    }

    public Integer getIdCombo() {
        return idCombo;
    }

    public void setIdCombo(Integer idCombo) {
        this.idCombo = idCombo;
    }

    public Integer getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ComboProductoId that)) return false;
        return Objects.equals(idCombo, that.idCombo) && Objects.equals(idProducto, that.idProducto);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idCombo, idProducto);
    }
}