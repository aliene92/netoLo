#!/bin/bash
NS=app
SERVICES="frontend backend cache"

for src in $SERVICES; do
  for dst in $SERVICES; do
    [ "$src" = "$dst" ] && continue
    if microk8s kubectl exec -n "$NS" deploy/"$src" -- curl -s -o /dev/null -m 3 http://"$dst"; then
      res=ALLOWED
    else
      res=DENIED
    fi
    printf "%-10s -> %-10s : %s\n" "$src" "$dst" "$res"
  done
done
