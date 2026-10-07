// Toda chamada ao backend passa por aqui. O nginx do frontend repassa /api para o
// backend (nginx.conf); em desenvolvimento, o Vite faz o mesmo (vite.config.ts).
//   - acrescenta o token no cabeçalho Authorization;
//   - se o backend responder 401 com sessão aberta (token vencido ou inválido), limpa a
//     sessão e volta para o login (a chamada fica sem resposta: a página já está saindo);
//   - em erro, lança ApiError com a mensagem que o backend mandou em { "error": "..." }.
import { clearSession, getToken } from './session';

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

export async function api<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers);
  if (options.body) headers.set('Content-Type', 'application/json');
  const token = getToken();
  if (token) headers.set('Authorization', `Bearer ${token}`);

  const res = await fetch(`/api${path}`, { ...options, headers });

  if (res.status === 401 && token) {
    clearSession();
    window.location.assign('/login');
    return new Promise<T>(() => {});
  }
  if (!res.ok) {
    let message = '';
    try {
      const body = await res.json();
      message = body.error || body.message || '';
    } catch {
      // resposta sem JSON: fica a mensagem padrão de quem chamou
    }
    throw new ApiError(res.status, message);
  }

  const text = await res.text();
  return (text ? JSON.parse(text) : undefined) as T;
}
