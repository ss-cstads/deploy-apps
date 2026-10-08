package br.edu.ifsul.taskapi.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record TaskRequest(
    @NotBlank @Size(max = 200) String title,
    @Size(max = 1000) String description,
    Boolean completed
) {
    // "completed" é opcional no JSON: sem ele, a tarefa nasce não concluída
    public TaskRequest {
        if (completed == null) completed = false;
    }
}
