// API de mensagens em Java puro: só a biblioteca padrão, sem framework.
// O pipeline a compila em executável nativo com o GraalVM (sem JVM ao rodar).
// As mensagens ficam em memória: somem quando o app reinicia.
package exemplo;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class Main {

    record Mensagem(int id, String texto, Instant criadaEm) {
        String json() {
            return "{\"id\":" + id + ",\"texto\":\"" + escapar(texto) + "\",\"criada_em\":\"" + criadaEm + "\"}";
        }
    }

    static final List<Mensagem> mensagens = new ArrayList<>();
    static int proximoId = 1;

    // Sem biblioteca de JSON: basta achar o campo "texto" do corpo recebido
    static final Pattern CAMPO_TEXTO = Pattern.compile("\"texto\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");

    public static void main(String[] args) throws IOException {
        // O cluster informa a porta na variável PORT
        int porta = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
        HttpServer servidor = HttpServer.create(new InetSocketAddress(porta), 0);
        servidor.createContext("/api/mensagens", Main::mensagens);
        servidor.createContext("/", t -> {
            if (t.getRequestURI().getPath().equals("/")) responder(t, 200, "{\"status\":\"ok\",\"api\":\"/api/mensagens\"}");
            else responder(t, 404, "{\"erro\":\"rota inexistente\"}");
        });
        servidor.setExecutor(Executors.newFixedThreadPool(8));
        servidor.start();
        System.out.println("escutando na porta " + porta);
    }

    static void mensagens(HttpExchange t) throws IOException {
        switch (t.getRequestMethod()) {
            case "GET" -> {
                String lista;
                synchronized (mensagens) {
                    lista = mensagens.stream().map(Mensagem::json).collect(Collectors.joining(",", "[", "]"));
                }
                responder(t, 200, lista);
            }
            case "POST" -> {
                String corpo = new String(t.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
                Matcher m = CAMPO_TEXTO.matcher(corpo);
                String texto = m.find() ? m.group(1).replace("\\\"", "\"").replace("\\\\", "\\").strip() : "";
                if (texto.isEmpty()) {
                    responder(t, 400, "{\"erro\":\"envie {\\\"texto\\\": \\\"...\\\"}\"}");
                    return;
                }
                Mensagem nova;
                synchronized (mensagens) {
                    nova = new Mensagem(proximoId++, texto, Instant.now());
                    mensagens.add(nova);
                }
                responder(t, 201, nova.json());
            }
            default -> responder(t, 405, "{\"erro\":\"use GET ou POST\"}");
        }
    }

    static void responder(HttpExchange t, int status, String json) throws IOException {
        byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
        t.getResponseHeaders().set("Content-Type", "application/json; charset=utf-8");
        t.sendResponseHeaders(status, bytes.length);
        try (var saida = t.getResponseBody()) {
            saida.write(bytes);
        }
    }

    static String escapar(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
