// API de mensagens em Java com Micronaut.
// As mensagens ficam em memória: somem quando o app reinicia.
package exemplo;

import io.micronaut.http.HttpResponse;
import io.micronaut.http.annotation.Body;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;
import io.micronaut.http.annotation.Post;
import io.micronaut.serde.annotation.Serdeable;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

@Controller
public class MensagensController {

    @Serdeable
    public record Entrada(String texto) {}

    @Serdeable
    public record Mensagem(int id, String texto, Instant criadaEm) {}

    private final List<Mensagem> mensagens = new CopyOnWriteArrayList<>();
    private final AtomicInteger proximoId = new AtomicInteger(1);

    @Get("/")
    public Map<String, String> raiz() {
        return Map.of("status", "ok", "api", "/api/mensagens");
    }

    @Get("/api/mensagens")
    public List<Mensagem> listar() {
        return mensagens;
    }

    @Post("/api/mensagens")
    public HttpResponse<?> criar(@Body Entrada entrada) {
        String texto = entrada == null || entrada.texto() == null ? "" : entrada.texto().strip();
        if (texto.isEmpty()) {
            return HttpResponse.badRequest(Map.of("erro", "envie {\"texto\": \"...\"}"));
        }
        Mensagem nova = new Mensagem(proximoId.getAndIncrement(), texto, Instant.now());
        mensagens.add(nova);
        return HttpResponse.created(nova);
    }
}
