#!/bin/bash

find . -name '*.yaml' | while read FILE; do
  BASE_NAME=$(basename $FILE)
  if [ "$BASE_NAME" = kustomization.yaml ]; then
    continue
  fi
  OBJECT_NAME=$(echo $BASE_NAME | sed -e 's/\(.*\)-[a-z0-9]\+\.yaml/\1/')
  if ! grep "  name: $OBJECT_NAME" $FILE 1>/dev/null; then
    echo Error: $FILE
  fi
done
