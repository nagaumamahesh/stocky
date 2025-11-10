package services

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"backend/database"
	"backend/models"

	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

type RewardService struct{}

func NewRewardService() *RewardService {
	return &RewardService{}
}

// CreateReward creates a reward event and updates ledger with double-entry accounting
func (s *RewardService) CreateReward(req models.RewardRequest) (*models.RewardEvent, error) {
	userID, err := uuid.Parse(req.UserID)
	if err != nil {
		return nil, fmt.Errorf("invalid user_id: %w", err)
	}

	// Check if user exists
	var userExists bool
	err = database.DB.QueryRow(
		"SELECT CASE WHEN EXISTS(SELECT 1 FROM users WHERE id = @p1 AND deleted_at IS NULL) THEN 1 ELSE 0 END",
		userID,
	).Scan(&userExists)
	if err != nil {
		return nil, fmt.Errorf("error checking user existence: %w", err)
	}
	if !userExists {
		return nil, errors.New("user not found")
	}

	// Check for duplicate reference_id
	var existingID uuid.UUID
	err = database.DB.QueryRow(
		"SELECT id FROM reward_events WHERE reference_id = @p1 AND deleted_at IS NULL",
		req.ReferenceID,
	).Scan(&existingID)

	if err == nil {
		return nil, errors.New("duplicate reward event: reference_id already exists")
	} else if err != sql.ErrNoRows {
		return nil, fmt.Errorf("error checking duplicate: %w", err)
	}

	// Get current stock price
	stockPrice, err := s.getCurrentStockPrice(req.StockSymbol)
	if err != nil {
		return nil, fmt.Errorf("error getting stock price: %w", err)
	}

	// Calculate fees (brokerage, STT, GST, etc.)
	// Assuming 0.1% brokerage, 0.025% STT, 18% GST on brokerage
	brokerage := stockPrice * req.Quantity * 0.001
	stt := stockPrice * req.Quantity * 0.00025
	gst := brokerage * 0.18
	totalFees := brokerage + stt + gst
	totalCost := stockPrice*req.Quantity + totalFees

	// Start transaction
	tx, err := database.DB.Begin()
	if err != nil {
		return nil, fmt.Errorf("error starting transaction: %w", err)
	}
	defer tx.Rollback()

	transactionID := uuid.New()
	rewardID := uuid.New()

	// Create reward event
	_, err = tx.Exec(`
		INSERT INTO reward_events (id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status)
		VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
	`, rewardID, userID, req.StockSymbol, req.Quantity, req.RewardTimestamp, req.EventType, req.ReferenceID, "active")
	if err != nil {
		return nil, fmt.Errorf("error creating reward event: %w", err)
	}

	// Double-entry ledger: Debit Stock Inventory, Credit Cash
	// Entry 1: Debit Stock Inventory (Asset)
	_, err = tx.Exec(`
		INSERT INTO ledger_entries (transaction_id, account_type, account_symbol, debit_amount, credit_amount, stock_quantity, description, reference_id)
		VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
	`, transactionID, "stock_inventory", req.StockSymbol, stockPrice*req.Quantity, 0, req.Quantity,
		fmt.Sprintf("Stock reward: %s x %.6f", req.StockSymbol, req.Quantity), req.ReferenceID)
	if err != nil {
		return nil, fmt.Errorf("error creating ledger entry 1: %w", err)
	}

	// Entry 2: Credit Cash (Asset)
	_, err = tx.Exec(`
		INSERT INTO ledger_entries (transaction_id, account_type, account_symbol, debit_amount, credit_amount, stock_quantity, description, reference_id)
		VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
	`, transactionID, "cash", "", totalCost, 0, 0,
		fmt.Sprintf("Cash outflow for stock purchase: %s", req.StockSymbol), req.ReferenceID)
	if err != nil {
		return nil, fmt.Errorf("error creating ledger entry 2: %w", err)
	}

	// Entry 3: Debit Fees Expense
	_, err = tx.Exec(`
		INSERT INTO ledger_entries (transaction_id, account_type, account_symbol, debit_amount, credit_amount, stock_quantity, description, reference_id)
		VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
	`, transactionID, "fees_expense", "", totalFees, 0, 0,
		fmt.Sprintf("Brokerage, STT, GST for %s", req.StockSymbol), req.ReferenceID)
	if err != nil {
		return nil, fmt.Errorf("error creating ledger entry 3: %w", err)
	}

	// Entry 4: Credit Cash (for fees)
	_, err = tx.Exec(`
		INSERT INTO ledger_entries (transaction_id, account_type, account_symbol, debit_amount, credit_amount, stock_quantity, description, reference_id)
		VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
	`, transactionID, "cash", "", 0, totalFees, 0,
		fmt.Sprintf("Cash outflow for fees: %s", req.StockSymbol), req.ReferenceID)
	if err != nil {
		return nil, fmt.Errorf("error creating ledger entry 4: %w", err)
	}

	// Update or insert user holdings
	_, err = tx.Exec(`
		MERGE user_holdings AS target
		USING (SELECT @p1 AS user_id, @p2 AS stock_symbol, @p3 AS quantity) AS source
		ON target.user_id = source.user_id AND target.stock_symbol = source.stock_symbol
		WHEN MATCHED THEN
			UPDATE SET quantity = target.quantity + source.quantity, updated_at = GETUTCDATE(), last_updated = GETUTCDATE()
		WHEN NOT MATCHED THEN
			INSERT (user_id, stock_symbol, quantity, last_updated)
			VALUES (source.user_id, source.stock_symbol, source.quantity, GETUTCDATE());
	`, userID, req.StockSymbol, req.Quantity)
	if err != nil {
		return nil, fmt.Errorf("error updating user holdings: %w", err)
	}

	// Commit transaction
	if err = tx.Commit(); err != nil {
		return nil, fmt.Errorf("error committing transaction: %w", err)
	}

	// Fetch and return the created reward event
	reward := &models.RewardEvent{}
	err = database.DB.QueryRow(`
		SELECT id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status, created_at, updated_at
		FROM reward_events WHERE id = @p1
	`, rewardID).Scan(
		&reward.ID, &reward.UserID, &reward.StockSymbol, &reward.Quantity,
		&reward.RewardTimestamp, &reward.EventType, &reward.ReferenceID,
		&reward.Status, &reward.CreatedAt, &reward.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("error fetching created reward: %w", err)
	}

	logrus.WithFields(logrus.Fields{
		"user_id":      userID,
		"stock_symbol": req.StockSymbol,
		"quantity":     req.Quantity,
		"reference_id": req.ReferenceID,
	}).Info("Reward created successfully")

	return reward, nil
}

// GetTodayStocks returns all stock rewards for a user for today
func (s *RewardService) GetTodayStocks(userID uuid.UUID) ([]models.RewardEvent, error) {
	today := time.Now().UTC().Truncate(24 * time.Hour)
	tomorrow := today.Add(24 * time.Hour)

	rows, err := database.DB.Query(`
		SELECT id, user_id, stock_symbol, quantity, reward_timestamp, event_type, reference_id, status, created_at, updated_at
		FROM reward_events
		WHERE user_id = @p1 
			AND reward_timestamp >= @p2 
			AND reward_timestamp < @p3
			AND deleted_at IS NULL
		ORDER BY reward_timestamp DESC
	`, userID, today, tomorrow)
	if err != nil {
		return nil, fmt.Errorf("error querying today's stocks: %w", err)
	}
	defer rows.Close()

	var rewards []models.RewardEvent
	for rows.Next() {
		var reward models.RewardEvent
		err := rows.Scan(
			&reward.ID, &reward.UserID, &reward.StockSymbol, &reward.Quantity,
			&reward.RewardTimestamp, &reward.EventType, &reward.ReferenceID,
			&reward.Status, &reward.CreatedAt, &reward.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("error scanning reward: %w", err)
		}
		rewards = append(rewards, reward)
	}

	return rewards, nil
}

func (s *RewardService) getCurrentStockPrice(symbol string) (float64, error) {
	var price float64
	err := database.DB.QueryRow(`
		SELECT price FROM stock_prices WHERE stock_symbol = @p1 AND is_stale = 0
	`, symbol).Scan(&price)

	if err == sql.ErrNoRows {
		// If no price exists, fetch from price service
		priceService := NewStockPriceService()
		price, err = priceService.GetPrice(symbol)
		if err != nil {
			return 0, err
		}
		// Store the price
		priceService.UpdatePrice(symbol, price)
		return price, nil
	}

	if err != nil {
		return 0, fmt.Errorf("error getting stock price: %w", err)
	}

	return price, nil
}
