import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { portfolioAPI } from '../services/api';
import './Portfolio.css';

const Portfolio = () => {
  const { user } = useAuth();
  const [portfolio, setPortfolio] = useState([]);
  const [totalValue, setTotalValue] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (user?.id) {
      fetchPortfolio();
    }
  }, [user]);

  const fetchPortfolio = async () => {
    try {
      setLoading(true);
      
      // Skip API calls for admin users
      if (user?.role === 'admin') {
        setPortfolio([]);
        setTotalValue(0);
        setLoading(false);
        return;
      }
      
      const response = await portfolioAPI.getPortfolio(user.id);
      setPortfolio(response.data.holdings || []);
      setTotalValue(response.data.total_value || 0);
      setError('');
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to load portfolio');
      console.error('Portfolio error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading portfolio...</div>;
  }

  return (
    <div className="portfolio">
      <div className="portfolio-header">
        <h1>My Portfolio</h1>
        <div className="total-value">
          <span className="total-label">Total Value</span>
          <span className="total-amount">
            ₹{totalValue.toLocaleString('en-IN', {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            })}
          </span>
        </div>
      </div>

      {error && <div className="error">{error}</div>}

      {portfolio.length === 0 ? (
        <div className="card">
          <p className="empty-state">No holdings in your portfolio</p>
        </div>
      ) : (
        <div className="portfolio-grid">
          {portfolio.map((holding) => (
            <div key={holding.stock_symbol} className="holding-card">
              <div className="holding-header">
                <h3>{holding.stock_symbol}</h3>
                <span className="holding-price">
                  ₹{holding.price?.toLocaleString('en-IN', {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2,
                  }) || '0.00'}
                </span>
              </div>
              <div className="holding-details">
                <div className="detail-row">
                  <span className="detail-label">Quantity</span>
                  <span className="detail-value">
                    {holding.quantity.toFixed(6)} shares
                  </span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Current Value</span>
                  <span className="detail-value highlight">
                    ₹{holding.current_value?.toLocaleString('en-IN', {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2,
                    }) || '0.00'}
                  </span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Last Updated</span>
                  <span className="detail-value">
                    {new Date(holding.last_updated).toLocaleString()}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Portfolio;

