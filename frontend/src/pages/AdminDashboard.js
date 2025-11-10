import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { rewardAPI } from '../services/api';
import './AdminDashboard.css';

const AdminDashboard = () => {
  const { user } = useAuth();
  const [formData, setFormData] = useState({
    user_id: '',
    stock_symbol: '',
    quantity: '',
    reward_timestamp: new Date().toISOString().slice(0, 16),
    event_type: 'onboarding',
    reference_id: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const eventTypes = [
    'onboarding',
    'referral',
    'trading_milestone',
    'daily_bonus',
    'special_promotion',
  ];

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const generateReferenceId = () => {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 8);
    return `ref-${timestamp}-${random}`;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    // Generate reference ID if not provided
    const referenceId =
      formData.reference_id || generateReferenceId();

    try {
      const payload = {
        ...formData,
        quantity: parseFloat(formData.quantity),
        reward_timestamp: new Date(formData.reward_timestamp).toISOString(),
        reference_id: referenceId,
      };

      await rewardAPI.create(payload);
      setSuccess('Reward created successfully!');
      setFormData({
        user_id: '',
        stock_symbol: '',
        quantity: '',
        reward_timestamp: new Date().toISOString().slice(0, 16),
        event_type: 'onboarding',
        reference_id: '',
      });
    } catch (err) {
      setError(
        err.response?.data?.error ||
          err.response?.data?.details ||
          'Failed to create reward'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="admin-dashboard">
      <h1>Admin Dashboard</h1>
      <p className="page-subtitle">
        Create stock rewards for users
      </p>

      {error && <div className="error">{error}</div>}
      {success && <div className="success">{success}</div>}

      <div className="card">
        <h2>Create New Reward</h2>
        <form onSubmit={handleSubmit} className="reward-form">
          <div className="form-row">
            <div className="form-group">
              <label className="label">
                User ID (UUID) <span className="required">*</span>
              </label>
              <input
                type="text"
                name="user_id"
                className="input"
                value={formData.user_id}
                onChange={handleChange}
                placeholder="11111111-1111-1111-1111-111111111111"
                required
              />
              <small className="form-hint">
                Use a valid user UUID from the database
              </small>
            </div>

            <div className="form-group">
              <label className="label">
                Stock Symbol <span className="required">*</span>
              </label>
              <input
                type="text"
                name="stock_symbol"
                className="input"
                value={formData.stock_symbol}
                onChange={handleChange}
                placeholder="RELIANCE"
                required
                style={{ textTransform: 'uppercase' }}
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="label">
                Quantity <span className="required">*</span>
              </label>
              <input
                type="number"
                name="quantity"
                className="input"
                value={formData.quantity}
                onChange={handleChange}
                placeholder="10.5"
                step="0.000001"
                min="0.000001"
                required
              />
              <small className="form-hint">
                Enter quantity in shares (supports fractional shares)
              </small>
            </div>

            <div className="form-group">
              <label className="label">
                Event Type <span className="required">*</span>
              </label>
              <select
                name="event_type"
                className="input"
                value={formData.event_type}
                onChange={handleChange}
                required
              >
                {eventTypes.map((type) => (
                  <option key={type} value={type}>
                    {type.replace('_', ' ').toUpperCase()}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="label">
                Reward Timestamp <span className="required">*</span>
              </label>
              <input
                type="datetime-local"
                name="reward_timestamp"
                className="input"
                value={formData.reward_timestamp}
                onChange={handleChange}
                required
              />
            </div>

            <div className="form-group">
              <label className="label">Reference ID</label>
              <input
                type="text"
                name="reference_id"
                className="input"
                value={formData.reference_id}
                onChange={handleChange}
                placeholder="Auto-generated if left empty"
              />
              <small className="form-hint">
                Leave empty to auto-generate a unique reference ID
              </small>
            </div>
          </div>

          <div className="form-actions">
            <button
              type="submit"
              className="btn btn-primary"
              disabled={loading}
            >
              {loading ? 'Creating...' : 'Create Reward'}
            </button>
            <button
              type="button"
              className="btn btn-secondary"
              onClick={() => {
                setFormData({
                  user_id: '',
                  stock_symbol: '',
                  quantity: '',
                  reward_timestamp: new Date().toISOString().slice(0, 16),
                  event_type: 'onboarding',
                  reference_id: '',
                });
                setError('');
                setSuccess('');
              }}
            >
              Reset
            </button>
          </div>
        </form>
      </div>

      <div className="card">
        <h2>Quick Reference</h2>
        <div className="quick-ref">
          <div className="ref-section">
            <h3>Sample User IDs</h3>
            <ul>
              <li>11111111-1111-1111-1111-111111111111 (Rahul Sharma)</li>
              <li>22222222-2222-2222-2222-222222222222 (Priya Patel)</li>
              <li>33333333-3333-3333-3333-333333333333 (Amit Kumar)</li>
            </ul>
          </div>
          <div className="ref-section">
            <h3>Stock Symbols</h3>
            <ul>
              <li>RELIANCE, TCS, INFY, HDFCBANK, ICICIBANK</li>
              <li>BHARTIARTL, SBIN, BAJFINANCE, WIPRO, HINDUNILVR</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;

