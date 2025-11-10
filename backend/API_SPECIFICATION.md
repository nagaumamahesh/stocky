# API Specification

## Base URL
```
http://localhost:8080/api/v1
```

## Endpoints

### 1. Create Reward
**POST** `/reward`

Creates a new stock reward for a user and automatically updates the ledger with double-entry accounting.

#### Request Body
```json
{
  "user_id": "string (UUID)",
  "stock_symbol": "string",
  "quantity": "number (decimal)",
  "reward_timestamp": "string (ISO 8601 datetime)",
  "event_type": "string",
  "reference_id": "string (unique)"
}
```

#### Example Request
```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "stock_symbol": "RELIANCE",
  "quantity": 10.5,
  "reward_timestamp": "2024-01-15T10:30:00Z",
  "event_type": "onboarding",
  "reference_id": "ref-onboarding-001"
}
```

#### Success Response (201 Created)
```json
{
  "message": "Reward created successfully",
  "reward": {
    "id": "uuid",
    "user_id": "uuid",
    "stock_symbol": "RELIANCE",
    "quantity": 10.5,
    "reward_timestamp": "2024-01-15T10:30:00Z",
    "event_type": "onboarding",
    "reference_id": "ref-onboarding-001",
    "status": "active",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

#### Error Responses
- **400 Bad Request**: Invalid request payload
- **409 Conflict**: Duplicate reference_id
- **500 Internal Server Error**: Server error

---

### 2. Get Today's Stocks
**GET** `/today-stocks/:userId`

Returns all stock rewards for a user for the current day.

#### Path Parameters
- `userId` (string, UUID): User ID

#### Example Request
```
GET /api/v1/today-stocks/123e4567-e89b-12d3-a456-426614174000
```

#### Success Response (200 OK)
```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "rewards": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "stock_symbol": "RELIANCE",
      "quantity": 10.5,
      "reward_timestamp": "2024-01-15T10:30:00Z",
      "event_type": "onboarding",
      "reference_id": "ref-onboarding-001",
      "status": "active",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### Error Responses
- **400 Bad Request**: Invalid user ID
- **500 Internal Server Error**: Server error

---

### 3. Get Historical INR Values
**GET** `/historical-inr/:userId`

Returns the INR value of the user's portfolio for all past days (up to yesterday).

#### Path Parameters
- `userId` (string, UUID): User ID

#### Example Request
```
GET /api/v1/historical-inr/123e4567-e89b-12d3-a456-426614174000
```

#### Success Response (200 OK)
```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "historical_values": [
    {
      "date": "2024-01-14",
      "value": 26250.50
    },
    {
      "date": "2024-01-13",
      "value": 25000.00
    }
  ]
}
```

#### Error Responses
- **400 Bad Request**: Invalid user ID
- **500 Internal Server Error**: Server error

---

### 4. Get User Statistics
**GET** `/stats/:userId`

Returns statistics for a user including today's stock rewards and current portfolio value.

#### Path Parameters
- `userId` (string, UUID): User ID

#### Example Request
```
GET /api/v1/stats/123e4567-e89b-12d3-a456-426614174000
```

#### Success Response (200 OK)
```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "stats": {
    "today_stocks": {
      "RELIANCE": 10.5,
      "TCS": 5.0
    },
    "current_portfolio_value_inr": 52500.75
  }
}
```

#### Error Responses
- **400 Bad Request**: Invalid user ID
- **500 Internal Server Error**: Server error

---

### 5. Get User Portfolio
**GET** `/portfolio/:userId`

Returns detailed portfolio information with holdings per stock symbol and current INR values.

#### Path Parameters
- `userId` (string, UUID): User ID

#### Example Request
```
GET /api/v1/portfolio/123e4567-e89b-12d3-a456-426614174000
```

#### Success Response (200 OK)
```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "holdings": [
    {
      "stock_symbol": "RELIANCE",
      "quantity": 10.5,
      "price": 2500.00,
      "current_value": 26250.00,
      "last_updated": "2024-01-15T10:30:00Z"
    },
    {
      "stock_symbol": "TCS",
      "quantity": 5.0,
      "price": 3500.00,
      "current_value": 17500.00,
      "last_updated": "2024-01-15T10:30:00Z"
    }
  ],
  "total_value": 43750.00
}
```

#### Error Responses
- **400 Bad Request**: Invalid user ID
- **500 Internal Server Error**: Server error

---

### 6. Health Check
**GET** `/health`

Health check endpoint to verify service availability.

#### Example Request
```
GET /health
```

#### Success Response (200 OK)
```json
{
  "status": "healthy"
}
```

---

## Data Types

### Stock Symbol
- Type: String
- Format: Uppercase stock symbols (e.g., "RELIANCE", "TCS", "INFY")
- Max Length: 50 characters

### Quantity
- Type: Number (Decimal)
- Precision: Up to 6 decimal places
- Range: > 0
- Example: 10.5, 0.001, 100.123456

### INR Amount
- Type: Number (Decimal)
- Precision: Up to 4 decimal places
- Example: 26250.50, 1000.1234

### Timestamp
- Type: String
- Format: ISO 8601 (RFC3339)
- Example: "2024-01-15T10:30:00Z"

### UUID
- Type: String
- Format: Standard UUID v4
- Example: "123e4567-e89b-12d3-a456-426614174000"

---

## Error Response Format

All error responses follow this format:

```json
{
  "error": "Error message",
  "details": "Detailed error information (optional)"
}
```

---

## Rate Limiting

Currently, there are no rate limits implemented. This should be added in production.

---

## Authentication

Currently, there is no authentication implemented. This should be added in production.

