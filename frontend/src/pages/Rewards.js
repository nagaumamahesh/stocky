import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { rewardAPI } from '../services/api';
import './Rewards.css';

const Rewards = () => {
  const { user } = useAuth();
  const [todayStocks, setTodayStocks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    if (user?.id) {
      fetchTodayStocks();
    }
  }, [user]);

  const fetchTodayStocks = async () => {
    try {
      setLoading(true);
      
      // Skip API calls for admin users
      if (user?.role === 'admin') {
        setTodayStocks([]);
        setLoading(false);
        return;
      }
      
      const response = await rewardAPI.getTodayStocks(user.id);
      setTodayStocks(response.data.rewards || []);
      setError('');
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to load rewards');
      console.error('Rewards error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading rewards...</div>;
  }

  return (
    <div className="rewards">
      <h1>My Rewards</h1>
      <p className="page-subtitle">View all your stock rewards</p>

      {error && <div className="error">{error}</div>}
      {success && <div className="success">{success}</div>}

      <div className="card">
        <h2>Today's Rewards</h2>
        {todayStocks.length === 0 ? (
          <p className="empty-state">No rewards received today</p>
        ) : (
          <div className="rewards-table">
            <div className="table-header">
              <div className="table-cell">Stock</div>
              <div className="table-cell">Quantity</div>
              <div className="table-cell">Event Type</div>
              <div className="table-cell">Time</div>
              <div className="table-cell">Reference ID</div>
            </div>
            {todayStocks.map((reward) => (
              <div key={reward.id} className="table-row">
                <div className="table-cell">
                  <span className="stock-badge">{reward.stock_symbol}</span>
                </div>
                <div className="table-cell">
                  {reward.quantity.toFixed(6)} shares
                </div>
                <div className="table-cell">
                  <span className="event-badge">{reward.event_type}</span>
                </div>
                <div className="table-cell">
                  {new Date(reward.reward_timestamp).toLocaleString()}
                </div>
                <div className="table-cell">
                  <code className="reference-id">{reward.reference_id}</code>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="card">
        <h2>All Time Rewards Summary</h2>
        <div className="summary-stats">
          <div className="summary-item">
            <div className="summary-label">Total Rewards Today</div>
            <div className="summary-value">{todayStocks.length}</div>
          </div>
          <div className="summary-item">
            <div className="summary-label">Total Shares Today</div>
            <div className="summary-value">
              {todayStocks
                .reduce((sum, r) => sum + r.quantity, 0)
                .toFixed(6)}{' '}
              shares
            </div>
          </div>
          <div className="summary-item">
            <div className="summary-label">Unique Stocks</div>
            <div className="summary-value">
              {new Set(todayStocks.map((r) => r.stock_symbol)).size} stocks
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Rewards;

