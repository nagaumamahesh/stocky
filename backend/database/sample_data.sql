-- Sample Data for Stocky Backend
-- Execute this script in Azure SQL Server to populate test data

-- ============================================
-- 1. USERS
-- ============================================
-- Insert sample users
INSERT INTO users (id, email, created_at, updated_at)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'rahul.sharma@example.com', '2024-01-01T10:00:00Z', '2024-01-01T10:00:00Z'),
    ('22222222-2222-2222-2222-222222222222', 'priya.patel@example.com', '2024-01-02T11:00:00Z', '2024-01-02T11:00:00Z'),
    ('33333333-3333-3333-3333-333333333333', 'amit.kumar@example.com', '2024-01-03T12:00:00Z', '2024-01-03T12:00:00Z'),
    ('44444444-4444-4444-4444-444444444444', 'neha.singh@example.com', '2024-01-04T13:00:00Z', '2024-01-04T13:00:00Z'),
    ('55555555-5555-5555-5555-555555555555', 'vikram.reddy@example.com', '2024-01-05T14:00:00Z', '2024-01-05T14:00:00Z'),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin@stocky.com', '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z');

-- ============================================
-- 2. STOCK PRICES
-- ============================================
-- Insert current stock prices for popular Indian stocks
INSERT INTO stock_prices (id, stock_symbol, price, last_updated, is_stale, created_at, updated_at)
VALUES 
    (NEWID(), 'RELIANCE', 2450.75, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'TCS', 3520.50, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'INFY', 1485.25, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'HDFCBANK', 1680.00, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'ICICIBANK', 945.50, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'BHARTIARTL', 1185.75, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'SBIN', 595.25, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'BAJFINANCE', 6950.00, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'WIPRO', 445.50, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'HINDUNILVR', 2480.25, GETUTCDATE(), 0, GETUTCDATE(), GETUTCDATE());

-- ============================================
-- 3. STOCK PRICE HISTORY
-- ============================================
-- Insert historical prices for the past 7 days
DECLARE @today DATE = CAST(GETUTCDATE() AS DATE);
DECLARE @day1 DATE = DATEADD(DAY, -1, @today);
DECLARE @day2 DATE = DATEADD(DAY, -2, @today);
DECLARE @day3 DATE = DATEADD(DAY, -3, @today);
DECLARE @day4 DATE = DATEADD(DAY, -4, @today);
DECLARE @day5 DATE = DATEADD(DAY, -5, @today);
DECLARE @day6 DATE = DATEADD(DAY, -6, @today);
DECLARE @day7 DATE = DATEADD(DAY, -7, @today);

-- RELIANCE historical prices
INSERT INTO stock_price_history (id, stock_symbol, price, price_date, created_at)
VALUES 
    (NEWID(), 'RELIANCE', 2430.50, @day1, GETUTCDATE()),
    (NEWID(), 'RELIANCE', 2415.25, @day2, GETUTCDATE()),
    (NEWID(), 'RELIANCE', 2440.00, @day3, GETUTCDATE()),
    (NEWID(), 'RELIANCE', 2425.75, @day4, GETUTCDATE()),
    (NEWID(), 'RELIANCE', 2435.50, @day5, GETUTCDATE()),
    (NEWID(), 'RELIANCE', 2420.25, @day6, GETUTCDATE()),
    (NEWID(), 'RELIANCE', 2410.00, @day7, GETUTCDATE());

-- TCS historical prices
INSERT INTO stock_price_history (id, stock_symbol, price, price_date, created_at)
VALUES 
    (NEWID(), 'TCS', 3500.00, @day1, GETUTCDATE()),
    (NEWID(), 'TCS', 3510.25, @day2, GETUTCDATE()),
    (NEWID(), 'TCS', 3495.50, @day3, GETUTCDATE()),
    (NEWID(), 'TCS', 3525.75, @day4, GETUTCDATE()),
    (NEWID(), 'TCS', 3515.00, @day5, GETUTCDATE()),
    (NEWID(), 'TCS', 3505.25, @day6, GETUTCDATE()),
    (NEWID(), 'TCS', 3490.50, @day7, GETUTCDATE());

-- INFY historical prices
INSERT INTO stock_price_history (id, stock_symbol, price, price_date, created_at)
VALUES 
    (NEWID(), 'INFY', 1475.00, @day1, GETUTCDATE()),
    (NEWID(), 'INFY', 1480.25, @day2, GETUTCDATE()),
    (NEWID(), 'INFY', 1470.50, @day3, GETUTCDATE()),
    (NEWID(), 'INFY', 1485.75, @day4, GETUTCDATE()),
    (NEWID(), 'INFY', 1478.00, @day5, GETUTCDATE()),
    (NEWID(), 'INFY', 1472.25, @day6, GETUTCDATE()),
    (NEWID(), 'INFY', 1465.50, @day7, GETUTCDATE());

-- HDFCBANK historical prices
INSERT INTO stock_price_history (id, stock_symbol, price, price_date, created_at)
VALUES 
    (NEWID(), 'HDFCBANK', 1670.00, @day1, GETUTCDATE()),
    (NEWID(), 'HDFCBANK', 1675.25, @day2, GETUTCDATE()),
    (NEWID(), 'HDFCBANK', 1665.50, @day3, GETUTCDATE()),
    (NEWID(), 'HDFCBANK', 1685.75, @day4, GETUTCDATE()),
    (NEWID(), 'HDFCBANK', 1678.00, @day5, GETUTCDATE()),
    (NEWID(), 'HDFCBANK', 1672.25, @day6, GETUTCDATE()),
    (NEWID(), 'HDFCBANK', 1660.50, @day7, GETUTCDATE());

-- ============================================
-- 4. REWARD EVENTS
-- ============================================
-- Insert sample reward events for different users and scenarios

-- Rahul Sharma's rewards (User 1)
INSERT INTO reward_events (id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status, created_at, updated_at)
VALUES 
    -- Onboarding reward
    (NEWID(), '11111111-1111-1111-1111-111111111111', 'RELIANCE', 5.0, DATEADD(DAY, -10, GETUTCDATE()), 'onboarding', 'ref-onboard-rahul-001', 'active', DATEADD(DAY, -10, GETUTCDATE()), DATEADD(DAY, -10, GETUTCDATE())),
    -- Referral reward
    (NEWID(), '11111111-1111-1111-1111-111111111111', 'TCS', 2.5, DATEADD(DAY, -8, GETUTCDATE()), 'referral', 'ref-referral-rahul-001', 'active', DATEADD(DAY, -8, GETUTCDATE()), DATEADD(DAY, -8, GETUTCDATE())),
    -- Trading milestone
    (NEWID(), '11111111-1111-1111-1111-111111111111', 'INFY', 3.0, DATEADD(DAY, -5, GETUTCDATE()), 'trading_milestone', 'ref-milestone-rahul-001', 'active', DATEADD(DAY, -5, GETUTCDATE()), DATEADD(DAY, -5, GETUTCDATE())),
    -- Today's reward
    (NEWID(), '11111111-1111-1111-1111-111111111111', 'HDFCBANK', 1.5, CAST(GETUTCDATE() AS DATE), 'daily_bonus', 'ref-daily-rahul-001', 'active', GETUTCDATE(), GETUTCDATE());

-- Priya Patel's rewards (User 2)
INSERT INTO reward_events (id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status, created_at, updated_at)
VALUES 
    (NEWID(), '22222222-2222-2222-2222-222222222222', 'RELIANCE', 3.0, DATEADD(DAY, -9, GETUTCDATE()), 'onboarding', 'ref-onboard-priya-001', 'active', DATEADD(DAY, -9, GETUTCDATE()), DATEADD(DAY, -9, GETUTCDATE())),
    (NEWID(), '22222222-2222-2222-2222-222222222222', 'TCS', 1.0, DATEADD(DAY, -7, GETUTCDATE()), 'referral', 'ref-referral-priya-001', 'active', DATEADD(DAY, -7, GETUTCDATE()), DATEADD(DAY, -7, GETUTCDATE())),
    (NEWID(), '22222222-2222-2222-2222-222222222222', 'BHARTIARTL', 2.5, DATEADD(DAY, -4, GETUTCDATE()), 'trading_milestone', 'ref-milestone-priya-001', 'active', DATEADD(DAY, -4, GETUTCDATE()), DATEADD(DAY, -4, GETUTCDATE())),
    (NEWID(), '22222222-2222-2222-2222-222222222222', 'ICICIBANK', 2.0, CAST(GETUTCDATE() AS DATE), 'daily_bonus', 'ref-daily-priya-001', 'active', GETUTCDATE(), GETUTCDATE());

-- Amit Kumar's rewards (User 3)
INSERT INTO reward_events (id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status, created_at, updated_at)
VALUES 
    (NEWID(), '33333333-3333-3333-3333-333333333333', 'RELIANCE', 10.0, DATEADD(DAY, -12, GETUTCDATE()), 'onboarding', 'ref-onboard-amit-001', 'active', DATEADD(DAY, -12, GETUTCDATE()), DATEADD(DAY, -12, GETUTCDATE())),
    (NEWID(), '33333333-3333-3333-3333-333333333333', 'BAJFINANCE', 0.5, DATEADD(DAY, -6, GETUTCDATE()), 'referral', 'ref-referral-amit-001', 'active', DATEADD(DAY, -6, GETUTCDATE()), DATEADD(DAY, -6, GETUTCDATE())),
    (NEWID(), '33333333-3333-3333-3333-333333333333', 'WIPRO', 5.0, DATEADD(DAY, -3, GETUTCDATE()), 'trading_milestone', 'ref-milestone-amit-001', 'active', DATEADD(DAY, -3, GETUTCDATE()), DATEADD(DAY, -3, GETUTCDATE())),
    (NEWID(), '33333333-3333-3333-3333-333333333333', 'HINDUNILVR', 1.0, CAST(GETUTCDATE() AS DATE), 'daily_bonus', 'ref-daily-amit-001', 'active', GETUTCDATE(), GETUTCDATE());

-- Neha Singh's rewards (User 4)
INSERT INTO reward_events (id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status, created_at, updated_at)
VALUES 
    (NEWID(), '44444444-4444-4444-4444-444444444444', 'TCS', 4.0, DATEADD(DAY, -11, GETUTCDATE()), 'onboarding', 'ref-onboard-neha-001', 'active', DATEADD(DAY, -11, GETUTCDATE()), DATEADD(DAY, -11, GETUTCDATE())),
    (NEWID(), '44444444-4444-4444-4444-444444444444', 'INFY', 2.0, DATEADD(DAY, -9, GETUTCDATE()), 'referral', 'ref-referral-neha-001', 'active', DATEADD(DAY, -9, GETUTCDATE()), DATEADD(DAY, -9, GETUTCDATE())),
    (NEWID(), '44444444-4444-4444-4444-444444444444', 'SBIN', 3.5, DATEADD(DAY, -2, GETUTCDATE()), 'trading_milestone', 'ref-milestone-neha-001', 'active', DATEADD(DAY, -2, GETUTCDATE()), DATEADD(DAY, -2, GETUTCDATE()));

-- Vikram Reddy's rewards (User 5)
INSERT INTO reward_events (id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status, created_at, updated_at)
VALUES 
    (NEWID(), '55555555-5555-5555-5555-555555555555', 'HDFCBANK', 6.0, DATEADD(DAY, -8, GETUTCDATE()), 'onboarding', 'ref-onboard-vikram-001', 'active', DATEADD(DAY, -8, GETUTCDATE()), DATEADD(DAY, -8, GETUTCDATE())),
    (NEWID(), '55555555-5555-5555-5555-555555555555', 'RELIANCE', 2.0, DATEADD(DAY, -6, GETUTCDATE()), 'referral', 'ref-referral-vikram-001', 'active', DATEADD(DAY, -6, GETUTCDATE()), DATEADD(DAY, -6, GETUTCDATE())),
    (NEWID(), '55555555-5555-5555-5555-555555555555', 'TCS', 1.5, CAST(GETUTCDATE() AS DATE), 'daily_bonus', 'ref-daily-vikram-001', 'active', GETUTCDATE(), GETUTCDATE());

-- ============================================
-- 5. USER HOLDINGS (Denormalized)
-- ============================================
-- Calculate and insert user holdings based on reward events
-- Note: In production, this is maintained automatically via MERGE statements
-- Using MERGE to handle existing records gracefully

-- Rahul Sharma's holdings
MERGE user_holdings AS target
USING (SELECT '11111111-1111-1111-1111-111111111111' AS user_id, 'RELIANCE' AS stock_symbol, 5.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '11111111-1111-1111-1111-111111111111' AS user_id, 'TCS' AS stock_symbol, 2.5 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '11111111-1111-1111-1111-111111111111' AS user_id, 'INFY' AS stock_symbol, 3.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '11111111-1111-1111-1111-111111111111' AS user_id, 'HDFCBANK' AS stock_symbol, 1.5 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

-- Priya Patel's holdings
MERGE user_holdings AS target
USING (SELECT '22222222-2222-2222-2222-222222222222' AS user_id, 'RELIANCE' AS stock_symbol, 3.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '22222222-2222-2222-2222-222222222222' AS user_id, 'TCS' AS stock_symbol, 1.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '22222222-2222-2222-2222-222222222222' AS user_id, 'BHARTIARTL' AS stock_symbol, 2.5 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '22222222-2222-2222-2222-222222222222' AS user_id, 'ICICIBANK' AS stock_symbol, 2.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

-- Amit Kumar's holdings
MERGE user_holdings AS target
USING (SELECT '33333333-3333-3333-3333-333333333333' AS user_id, 'RELIANCE' AS stock_symbol, 10.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '33333333-3333-3333-3333-333333333333' AS user_id, 'BAJFINANCE' AS stock_symbol, 0.5 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '33333333-3333-3333-3333-333333333333' AS user_id, 'WIPRO' AS stock_symbol, 5.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '33333333-3333-3333-3333-333333333333' AS user_id, 'HINDUNILVR' AS stock_symbol, 1.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

-- Neha Singh's holdings
MERGE user_holdings AS target
USING (SELECT '44444444-4444-4444-4444-444444444444' AS user_id, 'TCS' AS stock_symbol, 4.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '44444444-4444-4444-4444-444444444444' AS user_id, 'INFY' AS stock_symbol, 2.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '44444444-4444-4444-4444-444444444444' AS user_id, 'SBIN' AS stock_symbol, 3.5 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

-- Vikram Reddy's holdings
MERGE user_holdings AS target
USING (SELECT '55555555-5555-5555-5555-555555555555' AS user_id, 'HDFCBANK' AS stock_symbol, 6.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '55555555-5555-5555-5555-555555555555' AS user_id, 'RELIANCE' AS stock_symbol, 2.0 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

MERGE user_holdings AS target
USING (SELECT '55555555-5555-5555-5555-555555555555' AS user_id, 'TCS' AS stock_symbol, 1.5 AS quantity) AS source
ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
WHEN MATCHED THEN
    UPDATE SET quantity = source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (id, user_id, stock_symbol, quantity, last_updated, created_at, updated_at)
    VALUES (NEWID(), source.user_id, source.stock_symbol, source.quantity, GETUTCDATE(), GETUTCDATE(), GETUTCDATE());

-- ============================================
-- 6. LEDGER ENTRIES (Sample)
-- ============================================
-- Note: In production, ledger entries are created automatically when rewards are created
-- This is just a sample to show the structure
-- For a complete ledger, you would need to run the reward creation API which generates these automatically

-- Sample ledger entry for a reward (showing double-entry structure)
-- This represents: Debit Stock Inventory, Credit Cash, Debit Fees, Credit Cash
DECLARE @sample_transaction_id UNIQUEIDENTIFIER = NEWID();
DECLARE @sample_reward_id NVARCHAR(255) = 'ref-sample-ledger-001';

-- Entry 1: Debit Stock Inventory
INSERT INTO ledger_entries (id, transaction_id, account_type, account_symbol, debit_amount, credit_amount, stock_quantity, description, reference_id, created_at, updated_at)
VALUES 
    (NEWID(), @sample_transaction_id, 'stock_inventory', 'RELIANCE', 12253.75, 0, 5.0, 'Stock reward: RELIANCE x 5.0', @sample_reward_id, GETUTCDATE(), GETUTCDATE()),
    -- Entry 2: Credit Cash (for stock purchase)
    (NEWID(), @sample_transaction_id, 'cash', '', 0, 12301.26, 0, 'Cash outflow for stock purchase: RELIANCE', @sample_reward_id, GETUTCDATE(), GETUTCDATE()),
    -- Entry 3: Debit Fees Expense
    (NEWID(), @sample_transaction_id, 'fees_expense', '', 47.51, 0, 0, 'Brokerage, STT, GST for RELIANCE', @sample_reward_id, GETUTCDATE(), GETUTCDATE()),
    -- Entry 4: Credit Cash (for fees)
    (NEWID(), @sample_transaction_id, 'cash', '', 0, 47.51, 0, 'Cash outflow for fees: RELIANCE', @sample_reward_id, GETUTCDATE(), GETUTCDATE());

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these queries to verify the data was inserted correctly

-- Check users
SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM users;

-- Check stock prices
SELECT 'Stock Prices' AS TableName, COUNT(*) AS RecordCount FROM stock_prices;

-- Check reward events
SELECT 'Reward Events' AS TableName, COUNT(*) AS RecordCount FROM reward_events;

-- Check user holdings
SELECT 'User Holdings' AS TableName, COUNT(*) AS RecordCount FROM user_holdings;

-- Check ledger entries
SELECT 'Ledger Entries' AS TableName, COUNT(*) AS RecordCount FROM ledger_entries;

-- View user portfolio summary
SELECT 
    u.email,
    uh.stock_symbol,
    uh.quantity,
    sp.price,
    uh.quantity * sp.price AS current_value
FROM users u
INNER JOIN user_holdings uh ON u.id = uh.user_id
LEFT JOIN stock_prices sp ON uh.stock_symbol = sp.stock_symbol
ORDER BY u.email, uh.stock_symbol;

-- View today's rewards
SELECT 
    u.email,
    re.stock_symbol,
    re.quantity,
    re.event_type,
    re.reward_timestamp
FROM reward_events re
INNER JOIN users u ON re.user_id = u.id
WHERE CAST(re.reward_timestamp AS DATE) = CAST(GETUTCDATE() AS DATE)
    AND re.deleted_at IS NULL
ORDER BY re.reward_timestamp DESC;

PRINT 'Sample data insertion completed successfully!';
PRINT 'Total Users: 5';
PRINT 'Total Stock Prices: 10';
PRINT 'Total Reward Events: 17';
PRINT 'Total User Holdings: 15';
PRINT 'Sample Ledger Entries: 4';

