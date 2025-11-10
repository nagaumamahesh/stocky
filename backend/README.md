# Backend - Azure SQL Server Connection

This Go application connects to an Azure SQL Server database.

## Setup

1. Create a `.env` file in the `backend` directory with the following variables:

```
DATABASE_SERVER=sqlserverresource.database.windows.net
DATABASE_USER=user
DATABASE_PASSWORD=June@db@2025
DATABASE_NAME=stocky
DATABASE_PORT=1433
```

2. Install dependencies (if not already done):
```bash
go mod tidy
```

3. Run the application:
```bash
go run main.go
```

The application will connect to the database and print "Connected to the database" if successful.

## Environment Variables

- `DATABASE_SERVER`: The Azure SQL Server hostname
- `DATABASE_USER`: Database username
- `DATABASE_PASSWORD`: Database password
- `DATABASE_NAME`: Database name
- `DATABASE_PORT`: Database port (default: 1433)

