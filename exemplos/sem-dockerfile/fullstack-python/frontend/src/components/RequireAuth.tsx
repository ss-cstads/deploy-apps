import type { ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { isLoggedIn } from '../services/session';

// Rota protegida: sem sessão, vai para o login.
export default function RequireAuth({ children }: { children: ReactNode }) {
  return isLoggedIn() ? <>{children}</> : <Navigate to="/login" replace />;
}
