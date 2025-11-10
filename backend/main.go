package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	_ "github.com/microsoft/go-mssqldb"
)

func main() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// Get database connection variables from environment
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
		log.Fatal("Missing required database environment variables: DATABASE_SERVER, DATABASE_USER, DATABASE_PASSWORD, DATABASE_NAME")
	}

	// Construct connection string for Azure SQL Server
	connString := fmt.Sprintf("server=tcp:%s,%s;user id=%s;password=%s;database=%s;encrypt=true;trust server certificate=true;connection timeout=30",
		server, port, user, password, database)

	// Connect to the database
	db, err := sql.Open("sqlserver", connString)
	if err != nil {
		log.Fatalf("Error opening database connection: %v", err)
	}
	defer db.Close()

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	}

	fmt.Println("Connected to the database")
}
