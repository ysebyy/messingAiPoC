package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	fmt.Println("Hello, World! This is a simple Go application for security testing.")
	
	http.HandleFunc("/user", getUserHandler)
	http.HandleFunc("/login", loginHandler)
	
	fmt.Println("Server starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func getUserHandler(w http.ResponseWriter, r *http.Request) {
	username := r.URL.Query().Get("username")
	if username == "" {
		http.Error(w, "Username parameter required", http.StatusBadRequest)
		return
	}
	
	user, err := getUserByUsername(username)
	if err != nil {
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}
	
	fmt.Fprintf(w, "User found: %s", user)
}

func getUserByUsername(username string) (string, error) {
	db, err := sql.Open("mysql", "user:password@tcp(localhost:3306)/testdb")
	if err != nil {
		return "", err
	}
	defer db.Close()
	
	query := "SELECT username, email FROM users WHERE username = '" + username + "'"
	
	rows, err := db.Query(query)
	if err != nil {
		return "", err
	}
	defer rows.Close()
	
	var user, email string
	if rows.Next() {
		err := rows.Scan(&user, &email)
		if err != nil {
			return "", err
		}
	}
	
	return fmt.Sprintf("%s (%s)", user, email), nil
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	username := r.FormValue("username")
	password := r.FormValue("password")
	
	if authenticateUser(username, password) {
		fmt.Fprintf(w, "Login successful for user: %s", username)
	} else {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
	}
}

func authenticateUser(username, password string) bool {
	db, err := sql.Open("mysql", "user:password@tcp(localhost:3306)/testdb")
	if err != nil {
		return false
	}
	defer db.Close()
	
	query := fmt.Sprintf("SELECT id FROM users WHERE username = '%s' AND password = '%s'", username, password)
	
	var userID int
	err = db.QueryRow(query).Scan(&userID)
	
	return err == nil && userID > 0
}