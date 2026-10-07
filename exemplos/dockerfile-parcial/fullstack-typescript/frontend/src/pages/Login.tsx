import { useState, type FormEvent, type MouseEvent } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { login, register } from '../services/auth';
import { isLoggedIn, type User } from '../services/session';

export default function Login({ onLogin }: { onLogin: (user: User) => void }) {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [isRegister, setIsRegister] = useState(false);

  if (isLoggedIn()) return <Navigate to="/" replace />;

  function toggleMode(e: MouseEvent) {
    e.preventDefault();
    setIsRegister(!isRegister);
    setError('');
  }

  async function submit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const user = isRegister
        ? await register(username, password, name)
        : await login(username, password);
      onLogin(user);
      navigate('/');
    } catch (err) {
      setLoading(false);
      setError((err instanceof Error && err.message) || 'Erro ao autenticar. Verifique suas credenciais.');
    }
  }

  return (
    <div className="login-container">
      <div className="card login-card">
        <h2>{isRegister ? 'Criar Conta' : 'Login'}</h2>
        <p className="subtitle">Task Manager — IFSUL</p>

        {error && <div className="alert alert-error">{error}</div>}

        <form onSubmit={submit}>
          {isRegister && (
            <div className="form-group">
              <label>Nome Completo</label>
              <input type="text" value={name} onChange={(e) => setName(e.target.value)}
                     placeholder="Seu nome" required />
            </div>
          )}

          <div className="form-group">
            <label>Usuario</label>
            <input type="text" value={username} onChange={(e) => setUsername(e.target.value)}
                   placeholder="Seu usuario" required />
          </div>

          <div className="form-group">
            <label>Senha</label>
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
                   placeholder="Sua senha" required />
          </div>

          <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
            {loading ? 'Aguarde...' : isRegister ? 'Criar Conta' : 'Entrar'}
          </button>
        </form>

        <p className="toggle-link">
          {isRegister ? 'Ja tem conta? ' : 'Nao tem conta? '}
          <a href="#" onClick={toggleMode}>{isRegister ? 'Faca login' : 'Cadastre-se'}</a>
        </p>
      </div>
    </div>
  );
}
