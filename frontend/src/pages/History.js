import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { portfolioAPI } from '../services/api';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import './History.css';

const History = () => {
  const { user } = useAuth();
  const [historicalData, setHistoricalData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (user?.id) {
      fetchHistoricalData();
    }
  }, [user]);

  const fetchHistoricalData = async () => {
    try {
      setLoading(true);
      
      // Skip API calls for admin users
      if (user?.role === 'admin') {
        setHistoricalData([]);
        setLoading(false);
        return;
      }
      
      const response = await portfolioAPI.getHistoricalINR(user.id);
      const data = (response.data.historical_values || []).map((item) => ({
        date: item.date,
        value: parseFloat(item.value) || 0,
      }));
      setHistoricalData(data.reverse()); // Show oldest to newest
      setError('');
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to load historical data');
      console.error('History error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading historical data...</div>;
  }

  return (
    <div className="history">
      <h1>Portfolio History</h1>
      <p className="page-subtitle">
        Track your portfolio value over time
      </p>

      {error && <div className="error">{error}</div>}

      {historicalData.length === 0 ? (
        <div className="card">
          <p className="empty-state">
            No historical data available. Start earning rewards to see your
            portfolio grow!
          </p>
        </div>
      ) : (
        <>
          <div className="card">
            <h2>Portfolio Value Trend</h2>
            <div className="chart-container">
              <ResponsiveContainer width="100%" height={400}>
                <LineChart data={historicalData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis
                    dataKey="date"
                    tick={{ fontSize: 12 }}
                    angle={-45}
                    textAnchor="end"
                    height={80}
                  />
                  <YAxis
                    tick={{ fontSize: 12 }}
                    tickFormatter={(value) =>
                      `₹${(value / 1000).toFixed(1)}k`
                    }
                  />
                  <Tooltip
                    formatter={(value) => [
                      `₹${value.toLocaleString('en-IN', {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2,
                      })}`,
                      'Portfolio Value',
                    ]}
                    labelStyle={{ color: '#1f2937' }}
                  />
                  <Legend />
                  <Line
                    type="monotone"
                    dataKey="value"
                    stroke="#2563eb"
                    strokeWidth={2}
                    dot={{ fill: '#2563eb', r: 4 }}
                    name="Portfolio Value (INR)"
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="card">
            <h2>Historical Data</h2>
            <div className="history-table">
              <div className="table-header">
                <div className="table-cell">Date</div>
                <div className="table-cell">Portfolio Value (INR)</div>
                <div className="table-cell">Change</div>
              </div>
              {historicalData.map((item, index) => {
                const previousValue =
                  index > 0 ? historicalData[index - 1].value : item.value;
                const change = item.value - previousValue;
                const changePercent =
                  previousValue > 0 ? (change / previousValue) * 100 : 0;

                return (
                  <div key={item.date} className="table-row">
                    <div className="table-cell">{item.date}</div>
                    <div className="table-cell">
                      ₹{item.value.toLocaleString('en-IN', {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2,
                      })}
                    </div>
                    <div
                      className={`table-cell ${
                        change >= 0 ? 'positive' : 'negative'
                      }`}
                    >
                      {index > 0 && (
                        <>
                          {change >= 0 ? '+' : ''}
                          ₹{change.toLocaleString('en-IN', {
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 2,
                          })}{' '}
                          ({changePercent >= 0 ? '+' : ''}
                          {changePercent.toFixed(2)}%)
                        </>
                      )}
                      {index === 0 && <span className="text-muted">-</span>}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default History;

