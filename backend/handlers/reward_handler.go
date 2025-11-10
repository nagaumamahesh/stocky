package handlers

import (
	"net/http"

	"backend/models"
	"backend/services"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/sirupsen/logrus"
)

type RewardHandler struct {
	rewardService *services.RewardService
}

func NewRewardHandler() *RewardHandler {
	return &RewardHandler{
		rewardService: services.NewRewardService(),
	}
}

// CreateReward handles POST /reward
func (h *RewardHandler) CreateReward(c *gin.Context) {
	var req models.RewardRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		logrus.WithError(err).Error("Invalid request payload")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request payload", "details": err.Error()})
		return
	}

	reward, err := h.rewardService.CreateReward(req)
	if err != nil {
		logrus.WithError(err).Error("Error creating reward")
		errMsg := err.Error()
		if errMsg == "duplicate reward event: reference_id already exists" {
			c.JSON(http.StatusConflict, gin.H{"error": errMsg})
			return
		}
		if errMsg == "user not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": errMsg})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create reward", "details": errMsg})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Reward created successfully",
		"reward":  reward,
	})
}

// GetTodayStocks handles GET /today-stocks/:userId
func (h *RewardHandler) GetTodayStocks(c *gin.Context) {
	userIDStr := c.Param("userId")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	rewards, err := h.rewardService.GetTodayStocks(userID)
	if err != nil {
		logrus.WithError(err).Error("Error fetching today's stocks")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch today's stocks", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id": userID,
		"rewards": rewards,
	})
}
