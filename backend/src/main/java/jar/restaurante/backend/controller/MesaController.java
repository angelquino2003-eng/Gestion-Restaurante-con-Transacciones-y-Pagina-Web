package jar.restaurante.backend.controller;

import jar.restaurante.backend.entity.EstadoMesa;
import jar.restaurante.backend.entity.Mesa;
import jar.restaurante.backend.repository.MesaRepository;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/mesas")
public class MesaController {

    private final MesaRepository mesaRepository;

    public MesaController(MesaRepository mesaRepository) {
        this.mesaRepository = mesaRepository;
    }

    @GetMapping
    public List<Mesa> listarTodas() {
        return mesaRepository.findAllByOrderByNumeroAsc();
    }

    @GetMapping("/estado/{estado}")
    public List<Mesa> listarPorEstado(@PathVariable EstadoMesa estado) {
        return mesaRepository.findByEstadoOrderByNumeroAsc(estado);
    }
}