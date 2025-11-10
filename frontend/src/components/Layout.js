import React from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import './Layout.css';

const Layout = () => {
  const { user, logout } = useAuth();
  const location = useLocation();

  const isActive = (path) => location.pathname === path;

  return (
    <div className="layout">
      <nav className="navbar">
        <div className="nav-container">
          <div className="nav-brand">
            <Link to="/dashboard">Stocky</Link>
          </div>
          <div className="nav-links">
            <Link
              to="/dashboard"
              className={isActive('/dashboard') ? 'active' : ''}
            >
              Dashboard
            </Link>
            <Link
              to="/portfolio"
              className={isActive('/portfolio') ? 'active' : ''}
            >
              Portfolio
            </Link>
            <Link to="/rewards" className={isActive('/rewards') ? 'active' : ''}>
              Rewards
            </Link>
            <Link to="/history" className={isActive('/history') ? 'active' : ''}>
              History
            </Link>
            {user?.role === 'admin' && (
              <Link
                to="/admin"
                className={isActive('/admin') ? 'active' : ''}
              >
                Admin
              </Link>
            )}
          </div>
          <div className="nav-user">
            <span className="user-name">{user?.email || user?.name}</span>
            {user?.role && (
              <span className="user-role badge">{user.role}</span>
            )}
            <button onClick={logout} className="btn btn-secondary">
              Logout
            </button>
          </div>
        </div>
      </nav>
      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
};

export default Layout;

