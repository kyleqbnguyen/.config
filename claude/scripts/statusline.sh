#!/bin/bash
formatTokens() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) {
      v = n / 1000000
      if (v == int(v)) printf "%dm", v
      else printf "%.1fm", v
    } else {
      v = n / 1000
      if (v == int(v)) printf "%dk", v
      else printf "%.1fk", v
    }
  }'
}

data=$(cat)
model=$(echo "$data" | jq -r '.model.display_name // "unknown"')
used=$(echo "$data" | jq -r '.context_window.used_percentage // 0')
total=$(echo "$data" | jq -r '.context_window.total_input_tokens // 0')
size=$(echo "$data" | jq -r '.context_window.context_window_size // 200000')
cost=$(echo "$data" | jq -r '.cost.total_cost_usd // 0')
printf "%s | %s%% (%s/%s tokens) | $%.4f\n" "$model" "$used" "$(formatTokens "$total")" "$(formatTokens "$size")" "$cost"
