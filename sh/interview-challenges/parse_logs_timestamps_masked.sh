#!/bin/bash
curl -s https://coderbyte.com/api/challenges/logs/web-logs-raw -O > /dev/null

awk '/coderbyte heroku\/router/ {print $10, $11}' web-logs-raw | \
  sed -e "s:MASKED:M:g" -e "s:request_id=::g" | \
  sed -e "s:fwd=\":[:g" -e "s:\"$:]:g"
