import { api } from './api';
import { saveSession, type User } from './session';

export async function login(username: string, password: string): Promise<User> {
  const user = await api<User>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username, password }),
  });
  saveSession(user);
  return user;
}

export async function register(username: string, password: string, name: string): Promise<User> {
  const user = await api<User>('/auth/register', {
    method: 'POST',
    body: JSON.stringify({ username, password, name }),
  });
  saveSession(user);
  return user;
}
