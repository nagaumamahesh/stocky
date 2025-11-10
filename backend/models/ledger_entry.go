package models

import (
	"time"

	"github.com/google/uuid"
)

type LedgerEntry struct {
	ID            uuid.UUID `json:"id" db:"id"`
	TransactionID uuid.UUID `json:"transaction_id" db:"transaction_id"`
	AccountType   string    `json:"account_type" db:"account_type"`
	AccountSymbol string    `json:"account_symbol,omitempty" db:"account_symbol"`
	DebitAmount   float64   `json:"debit_amount" db:"debit_amount"`
	CreditAmount  float64   `json:"credit_amount" db:"credit_amount"`
	StockQuantity float64   `json:"stock_quantity" db:"stock_quantity"`
	Description   string    `json:"description,omitempty" db:"description"`
	ReferenceID   string    `json:"reference_id,omitempty" db:"reference_id"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time `json:"updated_at" db:"updated_at"`
}

