package br.edu.ifsul.api;

import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/tarefas")
public class TarefaController {

    private final TarefaRepository repositorio;

    public TarefaController(TarefaRepository repositorio) {
        this.repositorio = repositorio;
    }

    @GetMapping
    public List<Tarefa> listar() {
        return repositorio.findAll();
    }

    @GetMapping("/{id}")
    public Tarefa buscar(@PathVariable Long id) {
        return repositorio.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "tarefa não encontrada"));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Tarefa criar(@Valid @RequestBody Tarefa tarefa) {
        return repositorio.save(tarefa);
    }

    @PutMapping("/{id}")
    public Tarefa atualizar(@PathVariable Long id, @Valid @RequestBody Tarefa dados) {
        Tarefa tarefa = buscar(id);
        tarefa.setTitulo(dados.getTitulo());
        tarefa.setDescricao(dados.getDescricao());
        tarefa.setConcluida(dados.isConcluida());
        return repositorio.save(tarefa);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void remover(@PathVariable Long id) {
        repositorio.delete(buscar(id));
    }
}
