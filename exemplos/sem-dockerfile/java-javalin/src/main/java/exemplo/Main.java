// API de mensagens em Java com Javalin.
// As mensagens ficam em memória: somem quando o app reinicia.
package exemplo;

import io.javalin.Javalin;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

public class Main {

    public record Entrada(String texto) {}
    public record Mensagem(int id, String texto, String criadaEm) {}

    public static void main(String[] args) {
        List<Mensagem> mensagens = new CopyOnWriteArrayList<>();
        AtomicInteger proximoId = new AtomicInteger(1);

        Javalin app = Javalin.create(config -> {
            config.routes.get("/", ctx -> ctx.json(Map.of("status", "ok", "api", "/api/mensagens")));

            config.routes.get("/api/mensagens", ctx -> ctx.json(mensagens));

            config.routes.post("/api/mensagens", ctx -> {
                Entrada entrada = ctx.bodyAsClass(Entrada.class);
                String texto = entrada.texto() == null ? "" : entrada.texto().strip();
                if (texto.isEmpty()) {
                    ctx.status(400).json(Map.of("erro", "envie {\"texto\": \"...\"}"));
                    return;
                }
                Mensagem nova = new Mensagem(proximoId.getAndIncrement(), texto, Instant.now().toString());
                mensagens.add(nova);
                ctx.status(201).json(nova);
            });
        });

        // O cluster informa a porta na variável PORT
        app.start(Integer.parseInt(System.getenv().getOrDefault("PORT", "8080")));
    }
}
