package main

import (
	"context"
	"os"
	"time"

	"backend/database"
	"backend/handlers"
	"backend/services"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/sirupsen/logrus"
)

func main() {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		logrus.Warn("Error loading .env file, using environment variables")
	}

	// Initialize logger
	logrus.SetFormatter(&logrus.JSONFormatter{})
	logrus.SetLevel(logrus.InfoLevel)

	// Connect to database
	if err := database.Connect(); err != nil {
		logrus.WithError(err).Fatal("Failed to connect to database")
	}
	defer database.Close()
	logrus.Info("Connected to the database")

	// Run database migration
	if err := database.Migrate(); err != nil {
		logrus.WithError(err).Warn("Database migration had errors, continuing anyway")
	}

	// Start background job for hourly price updates
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go startPriceUpdateJob(ctx)

	// Setup Gin router
	router := setupRouter()

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	logrus.Infof("Starting server on port %s", port)
	if err := router.Run(":" + port); err != nil {
		logrus.WithError(err).Fatal("Failed to start server")
	}
}

func setupRouter() *gin.Engine {
	router := gin.Default()

	// CORS middleware
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:3000", "http://localhost:3001"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization"}
	config.AllowCredentials = true
	router.Use(cors.New(config))

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "healthy"})
	})

	// API routes
	api := router.Group("/api/v1")
	{
		rewardHandler := handlers.NewRewardHandler()
		portfolioHandler := handlers.NewPortfolioHandler()

		api.POST("/reward", rewardHandler.CreateReward)
		api.GET("/today-stocks/:userId", rewardHandler.GetTodayStocks)
		api.GET("/historical-inr/:userId", portfolioHandler.GetHistoricalINR)
		api.GET("/stats/:userId", portfolioHandler.GetStats)
		api.GET("/portfolio/:userId", portfolioHandler.GetPortfolio)
	}

	return router
}

func startPriceUpdateJob(ctx context.Context) {
	ticker := time.NewTicker(1 * time.Hour)
	defer ticker.Stop()

	priceService := services.NewStockPriceService()

	// Run immediately on startup
	logrus.Info("Running initial stock price update")
	if err := priceService.UpdateAllPrices(); err != nil {
		logrus.WithError(err).Error("Error updating stock prices")
	}
	priceService.MarkStalePrices()

	// Run every hour
	for {
		select {
		case <-ctx.Done():
			logrus.Info("Price update job stopped")
			return
		case <-ticker.C:
			logrus.Info("Running hourly stock price update")
			if err := priceService.UpdateAllPrices(); err != nil {
				logrus.WithError(err).Error("Error updating stock prices")
			}
			priceService.MarkStalePrices()
		}
	}
}
