package models

import (
	"time"

	"github.com/google/uuid"
)

type StockPrice struct {
	ID          uuid.UUID `json:"id" db:"id"`
	StockSymbol string    `json:"stock_symbol" db:"stock_symbol"`
	Price       float64   `json:"price" db:"price"`
	LastUpdated time.Time `json:"last_updated" db:"last_updated"`
	IsStale     bool      `json:"is_stale" db:"is_stale"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type StockPriceHistory struct {
	ID          uuid.UUID `json:"id" db:"id"`
	StockSymbol string    `json:"stock_symbol" db:"stock_symbol"`
	Price       float64   `json:"price" db:"price"`
	PriceDate   time.Time `json:"price_date" db:"price_date"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
}
