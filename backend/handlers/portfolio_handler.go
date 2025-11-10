package handlers

import (
	"net/http"

	"backend/services"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

type PortfolioHandler struct {
	portfolioService *services.PortfolioService
}

func NewPortfolioHandler() *PortfolioHandler {
	return &PortfolioHandler{
		portfolioService: services.NewPortfolioService(),
	}
}

// GetHistoricalINR handles GET /historical-inr/:userId
func (h *PortfolioHandler) GetHistoricalINR(c *gin.Context) {
	userIDStr := c.Param("userId")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	historicalData, err := h.portfolioService.GetHistoricalINR(userID)
	if err != nil {
		logrus.WithError(err).Error("Error fetching historical INR data")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch historical data", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id": userID,
		"historical_values": historicalData,
	})
}

// GetStats handles GET /stats/:userId
func (h *PortfolioHandler) GetStats(c *gin.Context) {
	userIDStr := c.Param("userId")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	stats, err := h.portfolioService.GetStats(userID)
	if err != nil {
		logrus.WithError(err).Error("Error fetching stats")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch stats", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id": userID,
		"stats":   stats,
	})
}

// GetPortfolio handles GET /portfolio/:userId
func (h *PortfolioHandler) GetPortfolio(c *gin.Context) {
	userIDStr := c.Param("userId")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	portfolio, err := h.portfolioService.GetPortfolio(userID)
	if err != nil {
		logrus.WithError(err).Error("Error fetching portfolio")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch portfolio", "details": err.Error()})
		return
	}

	totalValue := 0.0
	for _, item := range portfolio {
		totalValue += item.CurrentValue
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":      userID,
		"holdings":     portfolio,
		"total_value":  totalValue,
	})
}

