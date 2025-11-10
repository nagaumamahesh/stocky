package database

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/microsoft/go-mssqldb"
)

var DB *sql.DB

// Connect initializes the database connection
func Connect() error {
	server := os.Getenv("DATABASE_SERVER")
	user := os.Getenv("DATABASE_USER")
	password := os.Getenv("DATABASE_PASSWORD")
	database := os.Getenv("DATABASE_NAME")
	port := os.Getenv("DATABASE_PORT")
	if port == "" {
		port = "1433"
	}

	// Validate required variables
	if server == "" || user == "" || password == "" || database == "" {
		return fmt.Errorf("missing required database environment variables")
	}

	// Construct connection string for Azure SQL Server
	connString := fmt.Sprintf("server=tcp:%s,%s;user id=%s;password=%s;database=%s;encrypt=true;trust server certificate=true;connection timeout=30",
		server, port, user, password, database)

	var err error
	DB, err = sql.Open("sqlserver", connString)
	if err != nil {
		return fmt.Errorf("error opening database connection: %w", err)
	}

	// Test the connection
	if err = DB.Ping(); err != nil {
		return fmt.Errorf("error connecting to database: %w", err)
	}

	return nil
}

// Close closes the database connection
func Close() error {
	if DB != nil {
		return DB.Close()
	}
	return nil
}
