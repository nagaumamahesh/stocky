import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import './Login.css';

const Login = () => {
  const [email, setEmail] = useState('');
  const [userId, setUserId] = useState('');
  const [role, setRole] = useState('user');
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  // Sample users for MVP - in production, this would be a real auth API
  const sampleUsers = {
    '11111111-1111-1111-1111-111111111111': { email: 'rahul.sharma@example.com', role: 'user' },
    '22222222-2222-2222-2222-222222222222': { email: 'priya.patel@example.com', role: 'user' },
    '33333333-3333-3333-3333-333333333333': { email: 'amit.kumar@example.com', role: 'user' },
    '44444444-4444-4444-4444-444444444444': { email: 'neha.singh@example.com', role: 'user' },
    '55555555-5555-5555-5555-555555555555': { email: 'vikram.reddy@example.com', role: 'user' },
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa': { email: 'admin@stocky.com', role: 'admin' },
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');

    if (!userId) {
      setError('Please enter a User ID');
      return;
    }

    const user = sampleUsers[userId];
    if (user) {
      login({
        id: userId,
        email: user.email,
        role: user.role,
      });
      navigate('/dashboard');
    } else {
      // Allow custom login for testing
      login({
        id: userId,
        email: email || `${userId}@example.com`,
        role: role,
      });
      navigate('/dashboard');
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>Stocky</h1>
        <p className="subtitle">Stock Rewards Platform</p>
        <form onSubmit={handleSubmit}>
          {error && <div className="error">{error}</div>}
          
          <div className="form-group">
            <label className="label">User ID (UUID)</label>
            <input
              type="text"
              className="input"
              value={userId}
              onChange={(e) => setUserId(e.target.value)}
              placeholder="e.g., 11111111-1111-1111-1111-111111111111"
              required
            />
            <small className="form-hint">
              Use sample user IDs from the database or enter a custom UUID
            </small>
          </div>

          <div className="form-group">
            <label className="label">Email (Optional)</label>
            <input
              type="email"
              className="input"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="your@email.com"
            />
          </div>

          <div className="form-group">
            <label className="label">Role</label>
            <select
              className="input"
              value={role}
              onChange={(e) => setRole(e.target.value)}
            >
              <option value="user">User</option>
              <option value="admin">Admin</option>
            </select>
          </div>

          <button type="submit" className="btn btn-primary btn-block">
            Login
          </button>
        </form>

        <div className="sample-users">
          <p className="sample-title">Sample User IDs:</p>
          <ul>
            <li>11111111-1111-1111-1111-111111111111 (Rahul Sharma)</li>
            <li>22222222-2222-2222-2222-222222222222 (Priya Patel)</li>
            <li>33333333-3333-3333-3333-333333333333 (Amit Kumar)</li>
            <li>aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa (Admin)</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default Login;

