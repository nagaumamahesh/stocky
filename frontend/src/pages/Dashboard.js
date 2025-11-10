import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { portfolioAPI, rewardAPI } from '../services/api';
import './Dashboard.css';

const Dashboard = () => {
  const { user } = useAuth();
  const [stats, setStats] = useState(null);
  const [todayStocks, setTodayStocks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (user?.id) {
      fetchDashboardData();
    }
  }, [user]);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      setError('');
      
      if (!user?.id) {
        setError('User ID not found. Please login again.');
        return;
      }

      // Skip API calls for admin users (they don't have portfolio data)
      if (user?.role === 'admin') {
        setStats({ today_stocks: {}, current_portfolio_value_inr: 0 });
        setTodayStocks([]);
        setLoading(false);
        return;
      }

      console.log('Fetching dashboard data for user:', user.id);
      
      const [statsRes, todayRes] = await Promise.all([
        portfolioAPI.getStats(user.id),
        rewardAPI.getTodayStocks(user.id),
      ]);

      console.log('Stats response:', statsRes.data);
      console.log('Today stocks response:', todayRes.data);

      setStats(statsRes.data.stats);
      setTodayStocks(todayRes.data.rewards || []);
    } catch (err) {
      console.error('Dashboard error details:', {
        message: err.message,
        response: err.response?.data,
        status: err.response?.status,
        url: err.config?.url,
      });
      
      const errorMessage = err.response?.data?.error 
        || err.response?.data?.details 
        || err.message 
        || 'Failed to load dashboard data. Please check if the backend is running.';
      
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading dashboard...</div>;
  }

  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      <p className="welcome-text">Welcome back, {user?.email || 'User'}!</p>
      
      {user?.role === 'admin' && (
        <div className="admin-notice">
          <p>You are logged in as an administrator. Use the Admin menu to create rewards.</p>
        </div>
      )}

      {error && <div className="error">{error}</div>}

      <div className="dashboard-grid">
        <div className="stat-card primary">
          <div className="stat-icon">₹</div>
          <div className="stat-content">
            <div className="stat-label">Current Portfolio Value</div>
            <div className="stat-value">
              ₹{stats?.current_portfolio_value_inr?.toLocaleString('en-IN', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              }) || '0.00'}
            </div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">📈</div>
          <div className="stat-content">
            <div className="stat-label">Today's Rewards</div>
            <div className="stat-value">
              {Object.keys(stats?.today_stocks || {}).length || 0} stocks
            </div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">📊</div>
          <div className="stat-content">
            <div className="stat-label">Total Holdings</div>
            <div className="stat-value">
              {Object.values(stats?.today_stocks || {}).reduce(
                (sum, qty) => sum + qty,
                0
              ).toFixed(2) || '0.00'} shares
            </div>
          </div>
        </div>
      </div>

      <div className="card">
        <h2>Today's Stock Rewards</h2>
        {todayStocks.length === 0 ? (
          <p className="empty-state">No rewards received today</p>
        ) : (
          <div className="rewards-list">
            {todayStocks.map((reward) => (
              <div key={reward.id} className="reward-item">
                <div className="reward-symbol">{reward.stock_symbol}</div>
                <div className="reward-details">
                  <div className="reward-quantity">
                    {reward.quantity.toFixed(6)} shares
                  </div>
                  <div className="reward-type">{reward.event_type}</div>
                  <div className="reward-time">
                    {new Date(reward.reward_timestamp).toLocaleTimeString()}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="card">
        <h2>Today's Rewards by Stock</h2>
        {Object.keys(stats?.today_stocks || {}).length === 0 ? (
          <p className="empty-state">No rewards today</p>
        ) : (
          <div className="stock-breakdown">
            {Object.entries(stats?.today_stocks || {}).map(([symbol, quantity]) => (
              <div key={symbol} className="stock-item">
                <span className="stock-symbol">{symbol}</span>
                <span className="stock-quantity">
                  {quantity.toFixed(6)} shares
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;

