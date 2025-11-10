package database

import (
	"os"
	"path/filepath"
	"strings"

	"github.com/sirupsen/logrus"
)

// Migrate runs the database schema migration
func Migrate() error {
	schemaPath := filepath.Join("database", "schema.sql")

	// Try relative path first, then absolute
	schemaSQL, err := os.ReadFile(schemaPath)
	if err != nil {
		// Try from project root
		schemaPath = filepath.Join("backend", "database", "schema.sql")
		schemaSQL, err = os.ReadFile(schemaPath)
		if err != nil {
			return err
		}
	}

	// Split by GO statements (SQL Server batch separator)
	batches := strings.Split(string(schemaSQL), "GO")

	for _, batch := range batches {
		batch = strings.TrimSpace(batch)
		if batch == "" {
			continue
		}

		_, err := DB.Exec(batch)
		if err != nil {
			logrus.WithError(err).Errorf("Error executing batch: %s", batch[:min(100, len(batch))])
			// Continue with other batches even if one fails (might already exist)
			continue
		}
	}

	logrus.Info("Database migration completed")
	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
