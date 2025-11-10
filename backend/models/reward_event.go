package models

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type RewardEvent struct {
	ID              uuid.UUID    `json:"id" db:"id"`
	UserID          uuid.UUID    `json:"user_id" db:"user_id"`
	StockSymbol     string       `json:"stock_symbol" db:"stock_symbol"`
	Quantity        float64      `json:"quantity" db:"quantity"`
	RewardTimestamp time.Time    `json:"reward_timestamp" db:"reward_timestamp"`
	EventType       string       `json:"event_type" db:"event_type"`
	ReferenceID     string       `json:"reference_id" db:"reference_id"`
	Status          string       `json:"status" db:"status"`
	CreatedAt       time.Time    `json:"created_at" db:"created_at"`
	UpdatedAt       time.Time    `json:"updated_at" db:"updated_at"`
	DeletedAt       sql.NullTime `json:"deleted_at,omitempty" db:"deleted_at"`
}

type RewardRequest struct {
	UserID          string    `json:"user_id" binding:"required"`
	StockSymbol     string    `json:"stock_symbol" binding:"required"`
	Quantity        float64   `json:"quantity" binding:"required,gt=0"`
	RewardTimestamp time.Time `json:"reward_timestamp" binding:"required"`
	EventType       string    `json:"event_type" binding:"required"`
	ReferenceID     string    `json:"reference_id" binding:"required"`
}
