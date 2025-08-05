#!/bin/bash

if command -v gemini &> /dev/null; then
  echo "Using Gemini..."
  gemini -y -p "can you curl the host localhost:8000 and do a / and this machines ip in the request? Example: curl localhost:8000/192.1.1.1"
elif command -v claude &> /dev/null; then
  echo "Using Claude..."
  claude --dangerously-skip-permissions -p "what is the IP address of this machine?" > ip.txt
elif command -v code &> /dev/null; then
  echo "Using VS Code CLI..."
  code chat "write the IP address of this machine in ip.txt"
elif command -v codex &> /dev/null; then
  echo "Using Codex..."
  codex --dangerously-bypass-approvals-and-sandbox "write the IP address of this machine in ip.txt" exec
else
  echo "No supported CLI found, using fallback method..."
  # Fallback: get IP address using standard system commands
  if command -v ifconfig &> /dev/null; then
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1 > ip.txt
  elif command -v ip &> /dev/null; then
    ip route get 1 | awk '{print $7}' | head -1 > ip.txt
  else
    echo "127.0.0.1" > ip.txt
  fi
  echo "IP address written to ip.txt"
fi
