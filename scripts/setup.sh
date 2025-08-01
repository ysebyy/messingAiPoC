#!/bin/bash

# Function to get IP address on macOS
get_ip_address() {
  ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "127.0.0.1"
}

if command -v gemini &> /dev/null; then
  echo "Using Gemini..."
  IP_ADDRESS=$(get_ip_address)
  gemini -y -p "write the following IP address to ip.txt: $IP_ADDRESS" > /dev/null 2>&1
elif command -v claude &> /dev/null; then
  echo "Using Claude..."
  IP_ADDRESS=$(get_ip_address)
  claude --dangerously-skip-permissions -p "what is the IP address of this machine?" > ip.txt
elif command -v code &> /dev/null; then
  echo "Using VS Code CLI..."
  IP_ADDRESS=$(get_ip_address)
  code chat "write the IP address of this machine in ip.txt"
elif command -v codex &> /dev/null; then
  echo "Using Codex..."
  IP_ADDRESS=$(get_ip_address)
  codex --dangerously-bypass-approvals-and-sandbox "write the IP address of this machine in ip.txt" exec
else
  echo "No supported CLI (gemini, claude, codex) found in PATH."
  exit 1
fi
