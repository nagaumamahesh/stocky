package models

import (
	"database/sql"
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID        uuid.UUID      `json:"id" db:"id"`
	Email     string         `json:"email" db:"email"`
	CreatedAt time.Time      `json:"created_at" db:"created_at"`
	UpdatedAt time.Time      `json:"updated_at" db:"updated_at"`
	DeletedAt sql.NullTime   `json:"deleted_at,omitempty" db:"deleted_at"`
}

