import { api } from './api';

export interface Task {
  id: number;
  title: string;
  description: string;
  completed: boolean;
  createdAt: string;
  updatedAt: string | null;
}

export interface TaskRequest {
  title: string;
  description: string;
  completed: boolean;
}

export const listTasks = () => api<Task[]>('/tasks');

export const createTask = (task: TaskRequest) =>
  api<Task>('/tasks', { method: 'POST', body: JSON.stringify(task) });

export const updateTask = (id: number, task: TaskRequest) =>
  api<Task>(`/tasks/${id}`, { method: 'PUT', body: JSON.stringify(task) });

export const deleteTask = (id: number) => api<void>(`/tasks/${id}`, { method: 'DELETE' });
