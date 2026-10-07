// API de mensagens em C# (ASP.NET Core, minimal API).
// As mensagens ficam em memória: somem quando o app reinicia.
// A porta vem do cluster (variável PORT); o pipeline já sobe o app nela.
using System.Collections.Concurrent;

var app = WebApplication.CreateBuilder(args).Build();

var mensagens = new ConcurrentQueue<Mensagem>();
var proximoId = 0;

app.MapGet("/", () => new { status = "ok", api = "/api/mensagens" });

app.MapGet("/api/mensagens", () => mensagens);

app.MapPost("/api/mensagens", (Entrada entrada) =>
{
    var texto = entrada.Texto?.Trim();
    if (string.IsNullOrEmpty(texto))
        return Results.BadRequest(new { erro = "envie {\"texto\": \"...\"}" });
    var m = new Mensagem(Interlocked.Increment(ref proximoId), texto, DateTime.UtcNow);
    mensagens.Enqueue(m);
    return Results.Created($"/api/mensagens/{m.Id}", m);
});

app.Run();

record Entrada(string? Texto);
record Mensagem(int Id, string Texto, DateTime CriadaEm);
