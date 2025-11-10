# Stocky Backend API

A Golang backend service for managing stock rewards, portfolio tracking, and double-entry ledger accounting for Stocky - a platform where users earn shares of Indian stocks as incentives.

## Features

- **Reward Management**: Record stock rewards for users with event tracking
- **Double-Entry Ledger**: Automatic accounting for stock purchases, cash outflows, and fees
- **Portfolio Tracking**: Real-time and historical portfolio valuation in INR
- **Stock Price Management**: Hourly price updates with stale data detection
- **Edge Case Handling**: Duplicate prevention, stale data management, and error recovery

## Tech Stack

- **Language**: Go 1.21+
- **Framework**: Gin (HTTP web framework)
- **Database**: Azure SQL Server
- **Logging**: Logrus (structured logging)
- **Environment**: godotenv

## Project Structure

```
backend/
├── database/
│   ├── db.go           # Database connection
│   ├── migrate.go      # Schema migration
│   └── schema.sql      # Database schema
├── handlers/
│   ├── reward_handler.go      # Reward API handlers
│   └── portfolio_handler.go   # Portfolio API handlers
├── models/
│   ├── user.go
│   ├── reward_event.go
│   ├── ledger_entry.go
│   ├── stock_price.go
│   └── user_holding.go
├── services/
│   ├── reward_service.go      # Reward business logic
│   ├── stock_price_service.go # Stock price management
│   └── portfolio_service.go   # Portfolio calculations
├── main.go              # Application entry point
├── go.mod
└── README.md
```

## Setup

### Prerequisites

- Go 1.21 or higher
- Azure SQL Server database
- Environment variables configured

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd stocky/backend
```

2. Install dependencies:
```bash
go mod download
go mod tidy
```

3. Create a `.env` file in the `backend` directory:
```env
DATABASE_SERVER=sqlserverresource.database.windows.net
DATABASE_USER=user
DATABASE_PASSWORD=your_password
DATABASE_NAME=stocky
DATABASE_PORT=1433
PORT=8080
```

4. Run the application:
```bash
go run main.go
```

The server will start on port 8080 (or the port specified in the `PORT` environment variable).

## API Endpoints

### Health Check
- **GET** `/health` - Health check endpoint

### Reward Management
- **POST** `/api/v1/reward` - Create a new reward event
  ```json
  {
    "user_id": "uuid",
    "stock_symbol": "RELIANCE",
    "quantity": 10.5,
    "reward_timestamp": "2024-01-15T10:30:00Z",
    "event_type": "onboarding",
    "reference_id": "unique-reference-id"
  }
  ```

### User Queries
- **GET** `/api/v1/today-stocks/:userId` - Get all stock rewards for today
- **GET** `/api/v1/historical-inr/:userId` - Get historical INR values for all past days
- **GET** `/api/v1/stats/:userId` - Get user statistics (today's stocks and current portfolio value)
- **GET** `/api/v1/portfolio/:userId` - Get detailed portfolio with holdings per stock

## Database Schema

The database includes the following tables:

- **users**: User information
- **reward_events**: Stock reward events
- **ledger_entries**: Double-entry accounting ledger
- **stock_prices**: Current stock prices
- **stock_price_history**: Historical stock prices
- **user_holdings**: Denormalized user holdings for performance

See `database/schema.sql` for complete schema definition.

## Edge Cases Handled

### 1. Duplicate Reward Events
- Uses `reference_id` uniqueness constraint to prevent duplicate rewards
- Returns HTTP 409 Conflict if duplicate detected

### 2. Stale Price Data
- Prices older than 1 hour are marked as stale
- System automatically fetches fresh prices when needed
- Fallback to current price if historical price unavailable

### 3. Price API Downtime
- System continues to function with last known prices
- Stale data is clearly marked
- Automatic retry on next hourly update cycle

### 4. Rounding Errors
- Uses `DECIMAL(18, 6)` for stock quantities (6 decimal places)
- Uses `DECIMAL(18, 4)` for INR amounts (4 decimal places)
- All calculations maintain precision

### 5. Stock Adjustments/Refunds
- Support for soft deletes via `deleted_at` timestamp
- Status field in reward_events allows marking as inactive
- Ledger entries maintain full audit trail

## Background Jobs

### Hourly Price Updates
- Automatically runs every hour
- Updates prices for all stocks in the system
- Marks stale prices (>1 hour old)
- Runs immediately on application startup

## Double-Entry Accounting

When a reward is created, the system automatically creates ledger entries:

1. **Debit Stock Inventory** (Asset) - Stock received
2. **Credit Cash** (Asset) - Cash paid for stock
3. **Debit Fees Expense** - Brokerage, STT, GST
4. **Credit Cash** (Asset) - Cash paid for fees

This ensures the ledger always balances and provides complete financial tracking.

## Fee Calculation

The system calculates fees as follows:
- **Brokerage**: 0.1% of stock value
- **STT (Securities Transaction Tax)**: 0.025% of stock value
- **GST**: 18% of brokerage
- **Total Fees**: Sum of all above

## Stock Price Service

Currently uses a hypothetical price service that:
- Returns base prices for common Indian stocks (RELIANCE, TCS, INFY, etc.)
- Adds random variation (±5%) to simulate market fluctuations
- Can be easily replaced with real API integration

## Logging

The application uses structured logging with Logrus:
- JSON formatted logs
- Log levels: Info, Warn, Error
- Contextual fields for debugging

## Testing

To test the API endpoints, you can use curl or any HTTP client:

```bash
# Create a reward
curl -X POST http://localhost:8080/api/v1/reward \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "stock_symbol": "RELIANCE",
    "quantity": 10.5,
    "reward_timestamp": "2024-01-15T10:30:00Z",
    "event_type": "onboarding",
    "reference_id": "ref-001"
  }'

# Get today's stocks
curl http://localhost:8080/api/v1/today-stocks/123e4567-e89b-12d3-a456-426614174000

# Get portfolio
curl http://localhost:8080/api/v1/portfolio/123e4567-e89b-12d3-a456-426614174000
```

## Future Enhancements

- Real stock price API integration (NSE/BSE)
- Stock split and merger handling
- Refund/adjustment APIs
- User authentication and authorization
- Rate limiting
- Caching layer for frequently accessed data
- Unit and integration tests
- Docker containerization
- CI/CD pipeline

## Documentation

- [API Specification](./API_SPECIFICATION.md) - Detailed API endpoint documentation
- [Database Schema](./DATABASE_SCHEMA.md) - Complete database schema documentation
- [Edge Cases & Scaling](./EDGE_CASES.md) - Edge case handling and scaling considerations

## License

This project is part of a technical assignment.
