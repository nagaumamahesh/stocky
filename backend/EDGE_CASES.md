# Edge Cases and Solutions

This document describes how the Stocky backend handles various edge cases and scaling considerations.

## 1. Duplicate Reward Events / Replay Attacks

### Problem
Preventing the same reward from being processed multiple times, either accidentally or maliciously.

### Solution
- **Unique Constraint**: The `reference_id` field has a unique index with a WHERE clause excluding deleted records
- **Pre-insertion Check**: Before creating a reward, the system checks if a reward with the same `reference_id` already exists
- **HTTP 409 Conflict**: Returns a clear error message when a duplicate is detected
- **Idempotency**: The same `reference_id` can be safely retried without side effects

### Implementation
```go
// Check for duplicate reference_id before insertion
var existingID uuid.UUID
err = database.DB.QueryRow(
    "SELECT id FROM reward_events WHERE reference_id = @p1 AND deleted_at IS NULL",
    req.ReferenceID,
).Scan(&existingID)

if err == nil {
    return nil, errors.New("duplicate reward event: reference_id already exists")
}
```

---

## 2. Stock Splits, Mergers, or Delisting

### Problem
Handling corporate actions that affect stock quantities or availability.

### Solution
- **Status Field**: The `reward_events` table has a `status` field that can be set to 'active', 'inactive', or other states
- **Soft Deletes**: Uses `deleted_at` timestamp for soft deletion instead of hard deletes
- **Historical Data Preservation**: All historical data is preserved, allowing for adjustments
- **Future Enhancement**: Can add a `corporate_actions` table to track splits, mergers, and adjust holdings accordingly

### Current Implementation
- Status can be updated to mark rewards as inactive
- Historical calculations only consider active rewards
- Portfolio views filter by status

### Future Enhancement
```sql
-- Example future table for corporate actions
CREATE TABLE corporate_actions (
    id UNIQUEIDENTIFIER PRIMARY KEY,
    stock_symbol NVARCHAR(50),
    action_type NVARCHAR(50), -- 'split', 'merger', 'delisting'
    ratio DECIMAL(18, 6),
    effective_date DATE,
    ...
);
```

---

## 3. Rounding Errors in INR Valuation

### Problem
Preventing accumulation of rounding errors in financial calculations.

### Solution
- **Precise Data Types**: 
  - Stock quantities: `DECIMAL(18, 6)` - 6 decimal places
  - INR amounts: `DECIMAL(18, 4)` - 4 decimal places
- **Consistent Rounding**: All calculations maintain precision until final display
- **Database-Level Calculations**: Uses SQL Server's DECIMAL type for accurate arithmetic
- **No Floating Point**: Avoids float64 for financial calculations where possible

### Implementation
```go
// All quantities stored as float64 but calculated with precision
quantity := 10.123456  // 6 decimal places
price := 2500.1234     // 4 decimal places
value := quantity * price  // Maintains precision
```

---

## 4. Price API Downtime or Stale Data

### Problem
Handling situations where stock prices cannot be fetched or are outdated.

### Solution
- **Stale Data Detection**: Prices older than 1 hour are marked as `is_stale = 1`
- **Fallback Mechanism**: If current price unavailable, uses last known price
- **Historical Fallback**: For historical calculations, falls back to current price if historical price unavailable
- **Automatic Updates**: Hourly background job updates all prices
- **Graceful Degradation**: System continues to function with stale data, clearly marked

### Implementation
```go
// Mark stale prices
func (s *StockPriceService) MarkStalePrices() error {
    oneHourAgo := time.Now().UTC().Add(-1 * time.Hour)
    _, err := database.DB.Exec(`
        UPDATE stock_prices 
        SET is_stale = 1 
        WHERE last_updated < @p1
    `, oneHourAgo)
    return err
}

// Fallback to current price if historical unavailable
price, err := s.stockPriceService.GetHistoricalPrice(symbol, date)
if err != nil {
    price, _ = s.stockPriceService.GetPrice(symbol)
}
```

---

## 5. Adjustments/Refunds of Previously Given Rewards

### Problem
Handling corrections, refunds, or adjustments to previously issued rewards.

### Solution
- **Soft Deletes**: Uses `deleted_at` timestamp instead of hard deletes
- **Status Updates**: Can mark rewards as inactive without deleting
- **Audit Trail**: All ledger entries are preserved with `reference_id` linking
- **Reversal Entries**: Can create negative quantity rewards to reverse previous rewards
- **Transaction History**: Full transaction history maintained in ledger_entries

### Implementation
```go
// Mark reward as inactive (soft delete)
UPDATE reward_events 
SET status = 'inactive', updated_at = GETUTCDATE()
WHERE id = @p1

// Or create reversal entry
reward := RewardRequest{
    Quantity: -10.5,  // Negative quantity
    ReferenceID: "refund-ref-001",
    ...
}
```

### Future Enhancement
- Add explicit refund/adjustment API endpoint
- Create reversal ledger entries automatically
- Track adjustment reasons

---

## 6. Concurrent Reward Creation

### Problem
Handling multiple simultaneous reward creation requests for the same user or reference_id.

### Solution
- **Database Transactions**: All reward creation happens in a single transaction
- **Unique Constraints**: Database-level unique constraints prevent duplicates
- **Transaction Isolation**: SQL Server's default isolation level prevents race conditions
- **Error Handling**: Clear error messages for constraint violations

### Implementation
```go
// All operations in a single transaction
tx, err := database.DB.Begin()
// ... all operations ...
tx.Commit()
```

---

## 7. Large Portfolio Calculations

### Problem
Performance issues when calculating portfolio values for users with many holdings or long history.

### Solution
- **Denormalized Holdings**: `user_holdings` table provides fast access to current holdings
- **Indexed Queries**: All frequently queried columns are indexed
- **Date-Based Filtering**: Historical queries filter by date ranges
- **Pagination Ready**: API structure supports future pagination
- **Materialized Views**: Database views for common queries (vw_user_portfolio)

### Indexes
```sql
CREATE INDEX idx_reward_events_user_date ON reward_events(user_id, reward_timestamp) WHERE status = 'active';
CREATE UNIQUE INDEX idx_user_holdings_user_symbol ON user_holdings(user_id, stock_symbol);
```

---

## 8. Missing User Data

### Problem
Handling requests for non-existent users.

### Solution
- **User Validation**: Checks user existence before creating rewards
- **Clear Error Messages**: Returns HTTP 404 for non-existent users
- **Graceful Handling**: Portfolio queries return empty results instead of errors

### Implementation
```go
// Check if user exists
var userExists bool
err = database.DB.QueryRow(
    "SELECT CASE WHEN EXISTS(SELECT 1 FROM users WHERE id = @p1 AND deleted_at IS NULL) THEN 1 ELSE 0 END",
    userID,
).Scan(&userExists)
if !userExists {
    return nil, errors.New("user not found")
}
```

---

## 9. Invalid Stock Symbols

### Problem
Handling requests with invalid or unknown stock symbols.

### Solution
- **Flexible Price Service**: Price service handles unknown symbols with default pricing
- **No Hard Validation**: System doesn't reject unknown symbols, allowing for future stocks
- **Logging**: Unknown symbols are logged for monitoring

### Implementation
```go
basePrice, exists := basePrices[symbol]
if !exists {
    basePrice = 1000.0  // Default price
}
```

---

## 10. Database Connection Failures

### Problem
Handling database connectivity issues.

### Solution
- **Connection Pooling**: Uses Go's database/sql connection pooling
- **Error Logging**: All database errors are logged with context
- **Graceful Degradation**: Application continues running, returns errors to clients
- **Retry Logic**: Can be added for transient failures

---

## Scaling Considerations

### Database
- **Read Replicas**: Can add read replicas for portfolio queries
- **Partitioning**: Can partition reward_events by date for large datasets
- **Archiving**: Old reward events can be archived to separate tables

### Application
- **Caching**: Can add Redis cache for frequently accessed stock prices
- **Background Jobs**: Price updates run asynchronously
- **Horizontal Scaling**: Stateless API can be scaled horizontally
- **Load Balancing**: Multiple instances can share database connection pool

### API
- **Rate Limiting**: Should be added in production
- **Pagination**: Historical data queries should support pagination
- **Filtering**: Add date range filters for historical queries

---

## Monitoring and Observability

### Logging
- Structured logging with Logrus (JSON format)
- Contextual fields for debugging
- Error tracking with stack traces

### Metrics (Future)
- Request latency
- Database query performance
- Price update job success/failure rates
- Reward creation rates

### Alerts (Future)
- Database connection failures
- Price update job failures
- High error rates
- Stale price data warnings

