package jar.restaurante.backend.controller;

import jar.restaurante.backend.dto.ComboDTO;
import jar.restaurante.backend.repository.ComboRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/combos")
public class ComboController {

    private final ComboRepository comboRepository;

    public ComboController(ComboRepository comboRepository) {
        this.comboRepository = comboRepository;
    }

    @GetMapping
    public List<ComboDTO> listarActivos() {
        return comboRepository.findActivosConProductos()
                .stream()
                .map(ComboDTO::fromEntity)
                .toList();
    }
}