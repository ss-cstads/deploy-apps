import { useState } from 'react';
import { BrowserRouter, Link, Navigate, Route, Routes, useNavigate } from 'react-router-dom';
import RequireAuth from './components/RequireAuth';
import Login from './pages/Login';
import TaskList from './pages/TaskList';
import { clearSession, getUser, type User } from './services/session';

function Header({ user, onLogout }: { user: User | null; onLogout: () => void }) {
  const navigate = useNavigate();
  function logout() {
    onLogout();
    navigate('/login');
  }
  return (
    <header className="navbar">
      <div className="container navbar-content">
        <Link to="/" className="logo">Task Manager</Link>
        {user && (
          <nav>
            <span className="user-info">{user.name}</span>
            <button className="btn btn-sm btn-danger" onClick={logout}>Sair</button>
          </nav>
        )}
      </div>
    </header>
  );
}

export default function App() {
  // o usuário logado fica no estado do App para o cabeçalho acompanhar login e logout
  const [user, setUser] = useState<User | null>(getUser());

  function logout() {
    clearSession();
    setUser(null);
  }

  return (
    <BrowserRouter>
      <Header user={user} onLogout={logout} />
      <main className="container main-content">
        <Routes>
          <Route path="/login" element={<Login onLogin={setUser} />} />
          <Route path="/" element={<RequireAuth><TaskList /></RequireAuth>} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
      <footer className="footer">
        <div className="container">IFSUL — Campus Sapucaia do Sul | Cluster HashiCorp</div>
      </footer>
    </BrowserRouter>
  );
}
