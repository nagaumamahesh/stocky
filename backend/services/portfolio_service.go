package services

import (
	"fmt"
	"time"

	"backend/database"
	"backend/models"

	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

type PortfolioService struct {
	stockPriceService *StockPriceService
}

func NewPortfolioService() *PortfolioService {
	return &PortfolioService{
		stockPriceService: NewStockPriceService(),
	}
}

// GetHistoricalINR returns the INR value of user's portfolio for all past days
func (s *PortfolioService) GetHistoricalINR(userID uuid.UUID) ([]map[string]interface{}, error) {
	// Get all unique dates from reward events
	rows, err := database.DB.Query(`
		SELECT DISTINCT CAST(reward_timestamp AS DATE) AS reward_date
		FROM reward_events
		WHERE user_id = @p1 
			AND CAST(reward_timestamp AS DATE) < CAST(GETUTCDATE() AS DATE)
			AND status = 'active'
			AND deleted_at IS NULL
		ORDER BY reward_date DESC
	`, userID)
	if err != nil {
		return nil, fmt.Errorf("error querying historical dates: %w", err)
	}
	defer rows.Close()

	var dates []time.Time
	for rows.Next() {
		var date time.Time
		if err := rows.Scan(&date); err != nil {
			continue
		}
		dates = append(dates, date)
	}

	var results []map[string]interface{}
	for _, date := range dates {
		portfolioValue, err := s.calculatePortfolioValueForDate(userID, date)
		if err != nil {
			logrus.WithError(err).WithField("date", date).Error("Error calculating portfolio value")
			continue
		}

		results = append(results, map[string]interface{}{
			"date":  date.Format("2006-01-02"),
			"value": portfolioValue,
		})
	}

	return results, nil
}

// GetStats returns statistics for a user
func (s *PortfolioService) GetStats(userID uuid.UUID) (map[string]interface{}, error) {
	// Get today's rewards grouped by stock
	today := time.Now().UTC().Truncate(24 * time.Hour)
	tomorrow := today.Add(24 * time.Hour)

	rows, err := database.DB.Query(`
		SELECT stock_symbol, SUM(quantity) AS total_quantity
		FROM reward_events
		WHERE user_id = @p1 
			AND reward_timestamp >= @p2 
			AND reward_timestamp < @p3
			AND deleted_at IS NULL
		GROUP BY stock_symbol
	`, userID, today, tomorrow)
	if err != nil {
		return nil, fmt.Errorf("error querying today's stocks: %w", err)
	}
	defer rows.Close()

	todayStocks := make(map[string]float64)
	for rows.Next() {
		var symbol string
		var quantity float64
		if err := rows.Scan(&symbol, &quantity); err != nil {
			continue
		}
		todayStocks[symbol] = quantity
	}

	// Get current portfolio value
	currentValue, err := s.GetCurrentPortfolioValue(userID)
	if err != nil {
		return nil, fmt.Errorf("error getting current portfolio value: %w", err)
	}

	return map[string]interface{}{
		"today_stocks":                todayStocks,
		"current_portfolio_value_inr": currentValue,
	}, nil
}

// GetPortfolio returns the user's current portfolio with holdings per stock
func (s *PortfolioService) GetPortfolio(userID uuid.UUID) ([]models.PortfolioItem, error) {
	rows, err := database.DB.Query(`
		SELECT uh.stock_symbol, uh.quantity, 
			ISNULL(sp.price, 0) AS price,
			uh.quantity * ISNULL(sp.price, 0) AS current_value,
			uh.last_updated
		FROM user_holdings uh
		LEFT JOIN stock_prices sp ON uh.stock_symbol = sp.stock_symbol AND sp.is_stale = 0
		WHERE uh.user_id = @p1 AND uh.quantity > 0
		ORDER BY current_value DESC
	`, userID)
	if err != nil {
		return nil, fmt.Errorf("error querying portfolio: %w", err)
	}
	defer rows.Close()

	var portfolio []models.PortfolioItem
	for rows.Next() {
		var item models.PortfolioItem
		if err := rows.Scan(&item.StockSymbol, &item.Quantity, &item.Price, &item.CurrentValue, &item.LastUpdated); err != nil {
			continue
		}

		// If price is 0 or stale, fetch current price
		if item.Price == 0 {
			price, err := s.stockPriceService.GetPrice(item.StockSymbol)
			if err == nil {
				item.Price = price
				item.CurrentValue = item.Quantity * price
				s.stockPriceService.UpdatePrice(item.StockSymbol, price)
			}
		}

		portfolio = append(portfolio, item)
	}

	return portfolio, nil
}

// GetCurrentPortfolioValue returns the total INR value of user's portfolio
func (s *PortfolioService) GetCurrentPortfolioValue(userID uuid.UUID) (float64, error) {
	portfolio, err := s.GetPortfolio(userID)
	if err != nil {
		return 0, err
	}

	var totalValue float64
	for _, item := range portfolio {
		totalValue += item.CurrentValue
	}

	return totalValue, nil
}

// calculatePortfolioValueForDate calculates portfolio value for a specific date
func (s *PortfolioService) calculatePortfolioValueForDate(userID uuid.UUID, date time.Time) (float64, error) {
	dateOnly := date.Truncate(24 * time.Hour)

	rows, err := database.DB.Query(`
		SELECT 
			re.stock_symbol,
			SUM(re.quantity) AS total_quantity
		FROM reward_events re
		WHERE re.user_id = @p1
			AND CAST(re.reward_timestamp AS DATE) <= @p2
			AND re.status = 'active'
			AND re.deleted_at IS NULL
		GROUP BY re.stock_symbol
	`, userID, dateOnly)
	if err != nil {
		return 0, fmt.Errorf("error querying portfolio for date: %w", err)
	}
	defer rows.Close()

	var totalValue float64
	for rows.Next() {
		var symbol string
		var quantity float64
		if err := rows.Scan(&symbol, &quantity); err != nil {
			continue
		}

		// Get historical price for that date
		price, err := s.stockPriceService.GetHistoricalPrice(symbol, dateOnly)
		if err != nil {
			logrus.WithError(err).WithFields(logrus.Fields{
				"symbol": symbol,
				"date":   dateOnly,
			}).Warn("Error getting historical price, using current price")
			// Fallback to current price
			price, _ = s.stockPriceService.GetPrice(symbol)
		}

		totalValue += quantity * price
	}

	return totalValue, nil
}
