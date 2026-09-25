<?php
// Mural de recados: PHP + MySQL, sem framework.
// O cluster entrega a conexão pronta nas variáveis DB_HOST, DB_PORT, DB_NAME,
// DB_USER e DB_PASSWORD (database: true no deploy.yml).

$pdo = new PDO(
    sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        getenv('DB_HOST'), getenv('DB_PORT'), getenv('DB_NAME')),
    getenv('DB_USER'),
    getenv('DB_PASSWORD'),
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$pdo->exec('CREATE TABLE IF NOT EXISTS recados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    texto VARCHAR(500) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nome = trim($_POST['nome'] ?? '');
    $texto = trim($_POST['texto'] ?? '');
    if ($nome !== '' && $texto !== '') {
        $stmt = $pdo->prepare('INSERT INTO recados (nome, texto) VALUES (?, ?)');
        $stmt->execute([mb_substr($nome, 0, 80), mb_substr($texto, 0, 500)]);
    }
    header('Location: /');   // evita reenviar o formulário ao atualizar a página
    exit;
}

$recados = $pdo->query('SELECT nome, texto, criado_em FROM recados ORDER BY id DESC LIMIT 50')->fetchAll();

function e(string $s): string
{
    return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
}
?>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mural de recados</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 40rem; margin: 2rem auto; padding: 0 1rem; }
    form { display: grid; gap: .5rem; margin-bottom: 2rem; }
    input, textarea, button { font: inherit; padding: .5rem; }
    .recado { border-left: 4px solid #2f9e41; padding: .25rem 1rem; margin: 1rem 0; }
    small { color: #666; }
  </style>
</head>
<body>
  <h1>Mural de recados</h1>

  <form method="post">
    <input name="nome" placeholder="Seu nome" maxlength="80" required>
    <textarea name="texto" placeholder="Deixe um recado" maxlength="500" required></textarea>
    <button>Publicar</button>
  </form>

  <?php foreach ($recados as $r): ?>
    <div class="recado">
      <p><?= nl2br(e($r['texto'])) ?></p>
      <small><?= e($r['nome']) ?> — <?= e($r['criado_em']) ?></small>
    </div>
  <?php endforeach; ?>
</body>
</html>
