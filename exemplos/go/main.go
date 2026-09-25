// API de mensagens em Go, só com a biblioteca padrão.
// As mensagens ficam em memória: somem quando o app reinicia.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

type Mensagem struct {
	ID       int       `json:"id"`
	Texto    string    `json:"texto"`
	CriadaEm time.Time `json:"criada_em"`
}

var (
	mu        sync.Mutex
	mensagens []Mensagem
	proximoID = 1
)

func responderJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func listar(w http.ResponseWriter, r *http.Request) {
	mu.Lock()
	defer mu.Unlock()
	responderJSON(w, http.StatusOK, mensagens)
}

func criar(w http.ResponseWriter, r *http.Request) {
	var entrada struct {
		Texto string `json:"texto"`
	}
	if err := json.NewDecoder(r.Body).Decode(&entrada); err != nil || strings.TrimSpace(entrada.Texto) == "" {
		responderJSON(w, http.StatusBadRequest, map[string]string{"erro": `envie {"texto": "..."}`})
		return
	}
	mu.Lock()
	m := Mensagem{ID: proximoID, Texto: strings.TrimSpace(entrada.Texto), CriadaEm: time.Now()}
	proximoID++
	mensagens = append(mensagens, m)
	mu.Unlock()
	responderJSON(w, http.StatusCreated, m)
}

func main() {
	mensagens = []Mensagem{}

	http.HandleFunc("GET /api/mensagens", listar)
	http.HandleFunc("POST /api/mensagens", criar)
	http.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		responderJSON(w, http.StatusOK, map[string]string{"status": "ok", "api": "/api/mensagens"})
	})

	// O cluster informa a porta na variável PORT
	porta := os.Getenv("PORT")
	if porta == "" {
		porta = "8080"
	}
	log.Printf("escutando na porta %s", porta)
	log.Fatal(http.ListenAndServe(":"+porta, nil))
}
