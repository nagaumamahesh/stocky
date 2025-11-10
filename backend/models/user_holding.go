package models

import (
	"time"

	"github.com/google/uuid"
)

type UserHolding struct {
	ID          uuid.UUID `json:"id" db:"id"`
	UserID      uuid.UUID `json:"user_id" db:"user_id"`
	StockSymbol string    `json:"stock_symbol" db:"stock_symbol"`
	Quantity    float64   `json:"quantity" db:"quantity"`
	LastUpdated time.Time `json:"last_updated" db:"last_updated"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type PortfolioItem struct {
	StockSymbol  string    `json:"stock_symbol" db:"stock_symbol"`
	Quantity     float64   `json:"quantity" db:"quantity"`
	Price        float64   `json:"price" db:"price"`
	CurrentValue float64   `json:"current_value" db:"current_value"`
	LastUpdated  time.Time `json:"last_updated" db:"last_updated"`
}
