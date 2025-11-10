package services

import (
	"database/sql"
	"fmt"
	"math/rand"
	"time"

	"backend/database"

	"github.com/sirupsen/logrus"
)

type StockPriceService struct{}

func NewStockPriceService() *StockPriceService {
	return &StockPriceService{}
}

// GetPrice returns the current price for a stock symbol
// For now, this is a hypothetical service that returns random prices
func (s *StockPriceService) GetPrice(symbol string) (float64, error) {
	// Hypothetical price generation based on stock symbol
	// In production, this would call an external API
	rand.Seed(time.Now().UnixNano())

	// Base prices for common Indian stocks (hypothetical)
	basePrices := map[string]float64{
		"RELIANCE":   2500.0,
		"TCS":        3500.0,
		"INFY":       1500.0,
		"HDFCBANK":   1700.0,
		"ICICIBANK":  950.0,
		"BHARTIARTL": 1200.0,
		"SBIN":       600.0,
		"BAJFINANCE": 7000.0,
		"WIPRO":      450.0,
		"HINDUNILVR": 2500.0,
	}

	basePrice, exists := basePrices[symbol]
	if !exists {
		// Default base price for unknown stocks
		basePrice = 1000.0
	}

	// Add random variation (±5%)
	variation := (rand.Float64() - 0.5) * 0.1 // -5% to +5%
	price := basePrice * (1 + variation)

	// Round to 2 decimal places
	price = float64(int(price*100+0.5)) / 100

	logrus.WithFields(logrus.Fields{
		"symbol": symbol,
		"price":  price,
	}).Info("Fetched stock price")

	return price, nil
}

// UpdatePrice updates the stock price in the database
func (s *StockPriceService) UpdatePrice(symbol string, price float64) error {
	_, err := database.DB.Exec(`
		MERGE stock_prices AS target
		USING (SELECT @p1 AS stock_symbol, @p2 AS price, @p3 AS last_updated) AS source
		ON target.stock_symbol = source.stock_symbol
		WHEN MATCHED THEN
			UPDATE SET price = source.price, last_updated = source.last_updated, is_stale = 0, updated_at = GETUTCDATE()
		WHEN NOT MATCHED THEN
			INSERT (stock_symbol, price, last_updated, is_stale)
			VALUES (source.stock_symbol, source.price, source.last_updated, 0);
	`, symbol, price, time.Now().UTC())

	if err != nil {
		return fmt.Errorf("error updating stock price: %w", err)
	}

	return nil
}

// UpdateAllPrices fetches and updates prices for all stocks in the system
func (s *StockPriceService) UpdateAllPrices() error {
	rows, err := database.DB.Query(`
		SELECT DISTINCT stock_symbol FROM reward_events WHERE deleted_at IS NULL
		UNION
		SELECT stock_symbol FROM stock_prices
	`)
	if err != nil {
		return fmt.Errorf("error fetching stock symbols: %w", err)
	}
	defer rows.Close()

	var symbols []string
	for rows.Next() {
		var symbol string
		if err := rows.Scan(&symbol); err != nil {
			continue
		}
		symbols = append(symbols, symbol)
	}

	for _, symbol := range symbols {
		price, err := s.GetPrice(symbol)
		if err != nil {
			logrus.WithError(err).WithField("symbol", symbol).Error("Error fetching price")
			continue
		}

		if err := s.UpdatePrice(symbol, price); err != nil {
			logrus.WithError(err).WithField("symbol", symbol).Error("Error updating price")
			continue
		}
	}

	logrus.Info("Updated all stock prices")
	return nil
}

// MarkStalePrices marks prices older than 1 hour as stale
func (s *StockPriceService) MarkStalePrices() error {
	oneHourAgo := time.Now().UTC().Add(-1 * time.Hour)
	_, err := database.DB.Exec(`
		UPDATE stock_prices 
		SET is_stale = 1 
		WHERE last_updated < @p1
	`, oneHourAgo)

	if err != nil {
		return fmt.Errorf("error marking stale prices: %w", err)
	}

	return nil
}

// GetHistoricalPrice returns the price for a stock on a specific date
func (s *StockPriceService) GetHistoricalPrice(symbol string, date time.Time) (float64, error) {
	dateOnly := date.Truncate(24 * time.Hour)

	var price float64
	err := database.DB.QueryRow(`
		SELECT price FROM stock_price_history 
		WHERE stock_symbol = @p1 AND price_date = @p2
	`, symbol, dateOnly).Scan(&price)

	if err == sql.ErrNoRows {
		// If no historical price, use current price
		return s.GetPrice(symbol)
	}

	if err != nil {
		return 0, fmt.Errorf("error getting historical price: %w", err)
	}

	return price, nil
}

// SaveHistoricalPrice saves a price for a specific date
func (s *StockPriceService) SaveHistoricalPrice(symbol string, date time.Time, price float64) error {
	dateOnly := date.Truncate(24 * time.Hour)

	_, err := database.DB.Exec(`
		MERGE stock_price_history AS target
		USING (SELECT @p1 AS stock_symbol, @p2 AS price_date, @p3 AS price) AS source
		ON target.stock_symbol = source.stock_symbol AND target.price_date = source.price_date
		WHEN MATCHED THEN
			UPDATE SET price = source.price
		WHEN NOT MATCHED THEN
			INSERT (stock_symbol, price, price_date)
			VALUES (source.stock_symbol, source.price, source.price_date);
	`, symbol, dateOnly, price)

	if err != nil {
		return fmt.Errorf("error saving historical price: %w", err)
	}

	return nil
}
