package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func setupRouter() *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()

	podName := os.Getenv("HOSTNAME")
	if podName == "" {
		podName = "go-local-dev"
	}
	appVersion := os.Getenv("APP_VERSION")
	if appVersion == "" {
		appVersion = "v1.0.5"
	}

	inventoryDB := map[string]int{
		"1": 42, // Nike Air Max stock
		"2": 0,  // Adidas is sold out
	}

	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "UP", "pod": podName})
	})

	router.GET("/api/inventory/:id", func(c *gin.Context) {
		productID := c.Param("id")

		stockCount, exists := inventoryDB[productID]
		if !exists {
			c.JSON(http.StatusNotFound, gin.H{"error": "Inventory data not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"stockCount": stockCount,
			"_meta": gin.H{
				"service":  "inventory-service",
				"podName":  podName,
				"version":  appVersion,
				"language": "Go 1.25",
			},
		})
	})

	return router
}

func main() {
	router := setupRouter()

	if err := router.Run(":8082"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
