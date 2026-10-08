// API de mensagens em Java com Quarkus.
// As mensagens ficam em memória: somem quando o app reinicia.
package exemplo;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

@Path("/")
public class MensagensResource {

    public record Entrada(String texto) {}
    public record Mensagem(int id, String texto, Instant criadaEm) {}

    private static final List<Mensagem> mensagens = new CopyOnWriteArrayList<>();
    private static final AtomicInteger proximoId = new AtomicInteger(1);

    @GET
    public Map<String, String> raiz() {
        return Map.of("status", "ok", "api", "/api/mensagens");
    }

    @GET
    @Path("api/mensagens")
    public List<Mensagem> listar() {
        return mensagens;
    }

    @POST
    @Path("api/mensagens")
    public Response criar(Entrada entrada) {
        String texto = entrada == null || entrada.texto() == null ? "" : entrada.texto().strip();
        if (texto.isEmpty()) {
            return Response.status(400).entity(Map.of("erro", "envie {\"texto\": \"...\"}")).build();
        }
        Mensagem nova = new Mensagem(proximoId.getAndIncrement(), texto, Instant.now());
        mensagens.add(nova);
        return Response.status(201).entity(nova).build();
    }
}
