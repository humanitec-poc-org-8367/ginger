#!/usr/bin/env bash


DELTA_ID=$1
[[ -n "$2" ]] && HUMANITEC_SECRET=$2

curl  -X PATCH --header "Authorization: Bearer $HUMANITEC_SECRET" https://api.humanitec.io/orgs/htc-demo-04/apps/ginger/deltas/$DELTA_ID \
  --header 'Content-Type: application/json' \
  --data-raw '[{
                "modules": {
                  "update": {
                    "ginger": [{
                      "op": "add",
                      "path": "/deploy",
                      "value": {
                        "success": "available"
                      }
                    }]
                  }
                }
              }]'