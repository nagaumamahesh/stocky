# Database Schema Documentation

This document describes the database schema for the Stocky backend application.

## Overview

The database uses Azure SQL Server and implements a double-entry accounting system for tracking stock rewards, portfolio values, and financial transactions.

## Tables

### 1. users
Stores user information.

| Column | Type | Description |
|--------|------|-------------|
| id | UNIQUEIDENTIFIER | Primary key, auto-generated |
| email | NVARCHAR(255) | User email address (unique, not null) |
| created_at | DATETIME2 | Record creation timestamp |
| updated_at | DATETIME2 | Last update timestamp |
| deleted_at | DATETIME2 | Soft delete timestamp (nullable) |

**Indexes:**
- Primary key on `id`
- Unique index on `email` (where deleted_at IS NULL)
- Index on `deleted_at`

---

### 2. reward_events
Tracks all stock reward events for users.

| Column | Type | Description |
|--------|------|-------------|
| id | UNIQUEIDENTIFIER | Primary key, auto-generated |
| user_id | UNIQUEIDENTIFIER | Foreign key to users.id |
| stock_symbol | NVARCHAR(50) | Stock symbol (e.g., "RELIANCE") |
| quantity | DECIMAL(18, 6) | Stock quantity (6 decimal places) |
| reward_timestamp | DATETIME2 | When the reward was given |
| event_type | NVARCHAR(50) | Type of event (e.g., "onboarding", "referral") |
| reference_id | NVARCHAR(255) | Unique reference ID for idempotency |
| status | NVARCHAR(20) | Status (default: 'active') |
| created_at | DATETIME2 | Record creation timestamp |
| updated_at | DATETIME2 | Last update timestamp |
| deleted_at | DATETIME2 | Soft delete timestamp (nullable) |

**Indexes:**
- Primary key on `id`
- Foreign key to `users(id)`
- Unique index on `reference_id` (where deleted_at IS NULL)
- Index on `user_id`
- Index on `stock_symbol`
- Index on `reward_timestamp`
- Index on `deleted_at`
- Composite index on `(user_id, reward_timestamp)` where status = 'active'

---

### 3. ledger_entries
Double-entry accounting ledger for all financial transactions.

| Column | Type | Description |
|--------|------|-------------|
| id | UNIQUEIDENTIFIER | Primary key, auto-generated |
| transaction_id | UNIQUEIDENTIFIER | Groups related entries in a transaction |
| account_type | NVARCHAR(50) | Account type (e.g., "stock_inventory", "cash", "fees_expense") |
| account_symbol | NVARCHAR(50) | Stock symbol if applicable (nullable) |
| debit_amount | DECIMAL(18, 4) | Debit amount (4 decimal places) |
| credit_amount | DECIMAL(18, 4) | Credit amount (4 decimal places) |
| stock_quantity | DECIMAL(18, 6) | Stock quantity if applicable |
| description | NVARCHAR(500) | Transaction description (nullable) |
| reference_id | NVARCHAR(255) | Reference to reward event (nullable) |
| created_at | DATETIME2 | Record creation timestamp |
| updated_at | DATETIME2 | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `transaction_id`
- Index on `account_type`
- Index on `account_symbol`
- Index on `reference_id`
- Composite index on `(account_type, account_symbol)`

**Accounting Rules:**
- Each transaction has multiple entries that must balance
- Debits = Credits for each transaction
- Account types: stock_inventory, cash, fees_expense

---

### 4. stock_prices
Current stock prices with staleness tracking.

| Column | Type | Description |
|--------|------|-------------|
| id | UNIQUEIDENTIFIER | Primary key, auto-generated |
| stock_symbol | NVARCHAR(50) | Stock symbol (unique) |
| price | DECIMAL(18, 4) | Current price (4 decimal places) |
| last_updated | DATETIME2 | Last price update timestamp |
| is_stale | BIT | Whether price is stale (>1 hour old) |
| created_at | DATETIME2 | Record creation timestamp |
| updated_at | DATETIME2 | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Unique index on `stock_symbol`
- Index on `last_updated`

---

### 5. stock_price_history
Historical stock prices by date.

| Column | Type | Description |
|--------|------|-------------|
| id | UNIQUEIDENTIFIER | Primary key, auto-generated |
| stock_symbol | NVARCHAR(50) | Stock symbol |
| price | DECIMAL(18, 4) | Price on this date |
| price_date | DATE | Date of the price |
| created_at | DATETIME2 | Record creation timestamp |

**Indexes:**
- Primary key on `id`
- Unique composite index on `(stock_symbol, price_date)`

---

### 6. user_holdings
Denormalized table for fast portfolio queries.

| Column | Type | Description |
|--------|------|-------------|
| id | UNIQUEIDENTIFIER | Primary key, auto-generated |
| user_id | UNIQUEIDENTIFIER | Foreign key to users.id |
| stock_symbol | NVARCHAR(50) | Stock symbol |
| quantity | DECIMAL(18, 6) | Total quantity held |
| last_updated | DATETIME2 | Last update timestamp |
| created_at | DATETIME2 | Record creation timestamp |
| updated_at | DATETIME2 | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Foreign key to `users(id)`
- Unique composite index on `(user_id, stock_symbol)`
- Index on `user_id`
- Index on `stock_symbol`

**Note:** This table is maintained automatically via MERGE statements when rewards are created.

---

## Views

### vw_user_portfolio
Materialized view for user portfolio with current values.

```sql
SELECT 
    uh.user_id,
    uh.stock_symbol,
    uh.quantity,
    sp.price,
    uh.quantity * sp.price AS current_value,
    uh.last_updated
FROM user_holdings uh
LEFT JOIN stock_prices sp ON uh.stock_symbol = sp.stock_symbol
WHERE uh.quantity > 0;
```

---

## Stored Procedures

### sp_calculate_daily_portfolio_value
Calculates portfolio value for a user on a specific date.

**Parameters:**
- `@user_id` UNIQUEIDENTIFIER - User ID
- `@target_date` DATE - Target date

**Returns:**
- `stock_symbol` - Stock symbol
- `total_quantity` - Total quantity held
- `price` - Price on target date (historical or current)
- `total_value` - Total value (quantity * price)

---

## Data Types

### Precision Guidelines
- **Stock Quantities**: `DECIMAL(18, 6)` - 6 decimal places for fractional shares
- **INR Amounts**: `DECIMAL(18, 4)` - 4 decimal places for currency precision
- **Timestamps**: `DATETIME2` - UTC timestamps
- **Dates**: `DATE` - Date-only values

### UUIDs
All primary keys use `UNIQUEIDENTIFIER` (GUID/UUID) for:
- Distributed system compatibility
- Security (non-sequential IDs)
- Global uniqueness

---

## Relationships

```
users (1) ──< (many) reward_events
users (1) ──< (many) user_holdings
reward_events (many) ──< (many) ledger_entries (via reference_id)
stock_prices (1) ──< (many) stock_price_history (via stock_symbol)
```

---

## Constraints

### Unique Constraints
- `users.email` (where deleted_at IS NULL)
- `reward_events.reference_id` (where deleted_at IS NULL)
- `stock_prices.stock_symbol`
- `stock_price_history(stock_symbol, price_date)`
- `user_holdings(user_id, stock_symbol)`

### Foreign Key Constraints
- `reward_events.user_id` → `users.id`
- `user_holdings.user_id` → `users.id`

### Check Constraints
- `reward_events.quantity > 0` (enforced at application level)
- `ledger_entries.debit_amount >= 0` (enforced at application level)
- `ledger_entries.credit_amount >= 0` (enforced at application level)

---

## Indexing Strategy

### High-Read Queries
- User portfolio queries: Indexed on `user_id` and `stock_symbol`
- Historical queries: Indexed on `user_id` and `reward_timestamp`
- Price lookups: Unique index on `stock_symbol`

### Write Performance
- Minimal indexes on write-heavy tables
- Composite indexes for common query patterns
- Filtered indexes (WHERE clauses) to reduce index size

---

## Migration Notes

The schema is designed to be idempotent:
- Uses `IF NOT EXISTS` checks
- Can be run multiple times safely
- Handles existing objects gracefully

To run migrations:
1. Ensure database connection is configured
2. Application automatically runs migrations on startup
3. Or manually execute `database/schema.sql`

---

## Performance Considerations

1. **Denormalization**: `user_holdings` table denormalizes data for fast reads
2. **Indexing**: Strategic indexes on frequently queried columns
3. **Partitioning**: Can partition `reward_events` by date for large datasets
4. **Archiving**: Old data can be archived to separate tables

---

## Security Considerations

1. **Soft Deletes**: All tables support soft deletes via `deleted_at`
2. **Audit Trail**: All transactions tracked in `ledger_entries`
3. **Unique Constraints**: Prevent duplicate operations
4. **Parameterized Queries**: All queries use parameterized statements to prevent SQL injection

