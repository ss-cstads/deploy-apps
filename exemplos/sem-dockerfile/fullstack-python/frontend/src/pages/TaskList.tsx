import { useEffect, useState } from 'react';
import TaskForm from '../components/TaskForm';
import { deleteTask, listTasks, updateTask, type Task } from '../services/tasks';

// dd/MM/yyyy HH:mm
function formatDate(iso: string): string {
  const d = new Date(iso);
  if (isNaN(d.getTime())) return '';
  const p = (n: number) => String(n).padStart(2, '0');
  return `${p(d.getDate())}/${p(d.getMonth() + 1)}/${d.getFullYear()} ${p(d.getHours())}:${p(d.getMinutes())}`;
}

export default function TaskList() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);

  const [error, setError] = useState('');

  async function loadTasks() {
    setLoading(true);
    try {
      setTasks(await listTasks());
      setError('');
    } catch {
      setError('Nao foi possivel carregar as tarefas. Tente de novo em instantes.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadTasks();
  }, []);

  function onTaskSaved() {
    setShowForm(false);
    loadTasks();
  }

  async function toggleComplete(task: Task) {
    try {
      await updateTask(task.id, { title: task.title, description: task.description, completed: !task.completed });
    } catch {
      setError('Nao foi possivel atualizar a tarefa.');
    }
    loadTasks();
  }

  async function remove(task: Task) {
    if (!confirm(`Excluir "${task.title}"?`)) return;
    try {
      await deleteTask(task.id);
    } catch {
      setError('Nao foi possivel excluir a tarefa.');
    }
    loadTasks();
  }

  const completedCount = tasks.filter((t) => t.completed).length;

  return (
    <div className="task-page">
      <div className="header">
        <h1>Minhas Tarefas</h1>
        <button className="btn btn-primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Cancelar' : '+ Nova Tarefa'}
        </button>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      {showForm && <TaskForm onSaved={onTaskSaved} />}

      {tasks.length === 0 && !loading && !error && (
        <div className="empty-state card">
          <p>Nenhuma tarefa ainda. Clique em <strong>+ Nova Tarefa</strong> para comecar!</p>
        </div>
      )}

      <div className="task-list">
        {tasks.map((task) => (
          <div key={task.id} className={`card task-item${task.completed ? ' completed' : ''}`}>
            <div className="task-content">
              <div className="task-check">
                <input type="checkbox" checked={task.completed} onChange={() => toggleComplete(task)} />
              </div>
              <div className="task-info">
                <h3 className={task.completed ? 'task-done' : ''}>{task.title}</h3>
                {task.description && <p className="task-desc">{task.description}</p>}
                <span className="task-date">{formatDate(task.createdAt)}</span>
              </div>
              <div className="task-actions">
                <button className="btn btn-sm btn-danger" onClick={() => remove(task)}>Excluir</button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {tasks.length > 0 && (
        <div className="stats">{completedCount} de {tasks.length} tarefas concluidas</div>
      )}
    </div>
  );
}
