import { useState, type FormEvent } from 'react';
import { createTask } from '../services/tasks';

export default function TaskForm({ onSaved }: { onSaved: () => void }) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  async function submit(e: FormEvent) {
    e.preventDefault();
    if (!title.trim()) return;
    setSaving(true);
    setError('');
    try {
      await createTask({ title, description, completed: false });
      setTitle('');
      setDescription('');
      onSaved();
    } catch {
      setError('Nao foi possivel salvar a tarefa.');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="card form-card">
      <h3>Nova Tarefa</h3>
      {error && <div className="alert alert-error">{error}</div>}
      <form onSubmit={submit}>
        <div className="form-group">
          <input type="text" value={title} onChange={(e) => setTitle(e.target.value)}
                 placeholder="Titulo da tarefa" required autoFocus />
        </div>
        <div className="form-group">
          <textarea value={description} onChange={(e) => setDescription(e.target.value)}
                    placeholder="Descricao (opcional)" rows={3} />
        </div>
        <div className="form-actions">
          <button type="submit" className="btn btn-primary" disabled={!title.trim() || saving}>
            {saving ? 'Salvando...' : 'Salvar'}
          </button>
        </div>
      </form>
    </div>
  );
}
