package jar.restaurante.backend.controller;

import jar.restaurante.backend.dto.ProductoDTO;
import jar.restaurante.backend.repository.ProductoRepository;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/productos")
public class ProductoController {

    private final ProductoRepository productoRepository;

    public ProductoController(ProductoRepository productoRepository) {
        this.productoRepository = productoRepository;
    }

    @GetMapping
    public List<ProductoDTO> listarActivos() {
        return productoRepository.findActivosConCategoria()
                .stream()
                .map(ProductoDTO::fromEntity)
                .toList();
    }

    @GetMapping("/categoria/{idCategoria}")
    public List<ProductoDTO> listarPorCategoria(@PathVariable Integer idCategoria) {
        return productoRepository.findActivosPorCategoria(idCategoria)
                .stream()
                .map(ProductoDTO::fromEntity)
                .toList();
    }
}