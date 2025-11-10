-- Users table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND type in (N'U'))
BEGIN
    CREATE TABLE users (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        email NVARCHAR(255) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        deleted_at DATETIME2 NULL
    );
    
    CREATE UNIQUE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
    CREATE INDEX idx_users_deleted_at ON users(deleted_at);
END;

-- Reward Events table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reward_events]') AND type in (N'U'))
BEGIN
    CREATE TABLE reward_events (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        user_id UNIQUEIDENTIFIER NOT NULL,
        stock_symbol NVARCHAR(50) NOT NULL,
        quantity DECIMAL(18, 6) NOT NULL,
        reward_timestamp DATETIME2 NOT NULL,
        event_type NVARCHAR(50) NOT NULL,
        reference_id NVARCHAR(255) NOT NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'active',
        created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        deleted_at DATETIME2 NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
    );
    
    CREATE UNIQUE INDEX idx_reward_events_reference_id ON reward_events(reference_id) WHERE deleted_at IS NULL;
    CREATE INDEX idx_reward_events_user_id ON reward_events(user_id);
    CREATE INDEX idx_reward_events_stock_symbol ON reward_events(stock_symbol);
    CREATE INDEX idx_reward_events_reward_timestamp ON reward_events(reward_timestamp);
    CREATE INDEX idx_reward_events_deleted_at ON reward_events(deleted_at);
    CREATE INDEX idx_reward_events_user_date ON reward_events(user_id, reward_timestamp) WHERE status = 'active';
END;

-- Ledger Entries table (Double-entry accounting)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ledger_entries]') AND type in (N'U'))
BEGIN
    CREATE TABLE ledger_entries (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        transaction_id UNIQUEIDENTIFIER NOT NULL,
        account_type NVARCHAR(50) NOT NULL,
        account_symbol NVARCHAR(50) NULL,
        debit_amount DECIMAL(18, 4) NOT NULL DEFAULT 0,
        credit_amount DECIMAL(18, 4) NOT NULL DEFAULT 0,
        stock_quantity DECIMAL(18, 6) NOT NULL DEFAULT 0,
        description NVARCHAR(500) NULL,
        reference_id NVARCHAR(255) NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    
    CREATE INDEX idx_ledger_entries_transaction_id ON ledger_entries(transaction_id);
    CREATE INDEX idx_ledger_entries_account_type ON ledger_entries(account_type);
    CREATE INDEX idx_ledger_entries_account_symbol ON ledger_entries(account_symbol);
    CREATE INDEX idx_ledger_entries_reference_id ON ledger_entries(reference_id);
    CREATE INDEX idx_ledger_entries_accounts ON ledger_entries(account_type, account_symbol);
END;

-- Stock Prices table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stock_prices]') AND type in (N'U'))
BEGIN
    CREATE TABLE stock_prices (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        stock_symbol NVARCHAR(50) NOT NULL,
        price DECIMAL(18, 4) NOT NULL,
        last_updated DATETIME2 NOT NULL,
        is_stale BIT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    
    CREATE UNIQUE INDEX idx_stock_prices_stock_symbol ON stock_prices(stock_symbol);
    CREATE INDEX idx_stock_prices_last_updated ON stock_prices(last_updated);
END;

-- Stock Price History table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stock_price_history]') AND type in (N'U'))
BEGIN
    CREATE TABLE stock_price_history (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        stock_symbol NVARCHAR(50) NOT NULL,
        price DECIMAL(18, 4) NOT NULL,
        price_date DATE NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    
    CREATE UNIQUE INDEX idx_stock_price_history_symbol_date ON stock_price_history(stock_symbol, price_date);
END;

-- User Holdings table (Denormalized for performance)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_holdings]') AND type in (N'U'))
BEGIN
    CREATE TABLE user_holdings (
        id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        user_id UNIQUEIDENTIFIER NOT NULL,
        stock_symbol NVARCHAR(50) NOT NULL,
        quantity DECIMAL(18, 6) NOT NULL,
        last_updated DATETIME2 NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id)
    );
    
    CREATE UNIQUE INDEX idx_user_holdings_user_symbol ON user_holdings(user_id, stock_symbol);
    CREATE INDEX idx_user_holdings_user_id ON user_holdings(user_id);
    CREATE INDEX idx_user_holdings_stock_symbol ON user_holdings(stock_symbol);
END;

-- View for user portfolio
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_user_portfolio]'))
    DROP VIEW vw_user_portfolio;
GO

CREATE VIEW vw_user_portfolio AS
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
GO

-- Stored procedure for calculating daily portfolio value
IF EXISTS (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_calculate_daily_portfolio_value]'))
    DROP PROCEDURE sp_calculate_daily_portfolio_value;
GO

CREATE PROCEDURE sp_calculate_daily_portfolio_value
    @user_id UNIQUEIDENTIFIER,
    @target_date DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        re.stock_symbol,
        SUM(re.quantity) AS total_quantity,
        ISNULL(sph.price, sp.price) AS price,
        SUM(re.quantity) * ISNULL(sph.price, sp.price) AS total_value
    FROM reward_events re
    LEFT JOIN stock_price_history sph ON re.stock_symbol = sph.stock_symbol 
        AND CAST(re.reward_timestamp AS DATE) = sph.price_date
    LEFT JOIN stock_prices sp ON re.stock_symbol = sp.stock_symbol
    WHERE re.user_id = @user_id
        AND CAST(re.reward_timestamp AS DATE) <= @target_date
        AND re.status = 'active'
    GROUP BY re.stock_symbol, ISNULL(sph.price, sp.price);
END;
GO

