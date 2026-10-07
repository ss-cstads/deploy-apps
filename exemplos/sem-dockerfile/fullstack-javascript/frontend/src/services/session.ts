// Sessão do usuário no navegador (localStorage): o token JWT que o backend devolve no
// login/cadastro e os dados do usuário para mostrar no cabeçalho.
export interface User {
  token: string;
  username: string;
  name: string;
  role: string;
}

const TOKEN_KEY = 'auth_token';
const USER_KEY = 'auth_user';

export function saveSession(user: User): void {
  localStorage.setItem(TOKEN_KEY, user.token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearSession(): void {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function getUser(): User | null {
  const data = localStorage.getItem(USER_KEY);
  return data ? (JSON.parse(data) as User) : null;
}

export function isLoggedIn(): boolean {
  return !!getToken();
}
