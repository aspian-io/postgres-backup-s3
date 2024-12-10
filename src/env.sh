#!/bin/bash

set -euo pipefail

# If a corresponding *_FILE variable is set, read the secret from the file
if [ -n "${POSTGRES_USER_FILE:-}" ] && [ -f "${POSTGRES_USER_FILE}" ]; then
    POSTGRES_USER="$(cat "${POSTGRES_USER_FILE}")"
fi

if [ -n "${POSTGRES_PASSWORD_FILE:-}" ] && [ -f "${POSTGRES_PASSWORD_FILE}" ]; then
    POSTGRES_PASSWORD="$(cat "${POSTGRES_PASSWORD_FILE}")"
fi

if [ -n "${S3_ACCESS_KEY_ID_FILE:-}" ] && [ -f "${S3_ACCESS_KEY_ID_FILE}" ]; then
    S3_ACCESS_KEY_ID="$(cat "${S3_ACCESS_KEY_ID_FILE}")"
fi

if [ -n "${S3_SECRET_ACCESS_KEY_FILE:-}" ] && [ -f "${S3_SECRET_ACCESS_KEY_FILE}" ]; then
    S3_SECRET_ACCESS_KEY="$(cat "${S3_SECRET_ACCESS_KEY_FILE}")"
fi

if [ -n "${S3_BUCKET_FILE:-}" ] && [ -f "${S3_BUCKET_FILE}" ]; then
    S3_BUCKET="$(cat "${S3_BUCKET_FILE}")"
fi

if [ -n "${S3_ENDPOINT_FILE:-}" ] && [ -f "${S3_ENDPOINT_FILE}" ]; then
    S3_ENDPOINT="$(cat "${S3_ENDPOINT_FILE}")"
fi

# Validate required environment variables
if [ -z "${S3_BUCKET:-}" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "${POSTGRES_DATABASE:-}" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ -z "${POSTGRES_HOST:-}" ]; then
  # https://docs.docker.com/network/links/#environment-variables
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR:-}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ -z "${POSTGRES_USER:-}" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ -z "${POSTGRES_PASSWORD:-}" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable."
  exit 1
fi

if [ -z "${S3_ENDPOINT:-}" ]; then
  aws_args=""
else
  aws_args="--endpoint-url $S3_ENDPOINT"
fi

if [ -n "${S3_ACCESS_KEY_ID:-}" ]; then
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
fi

if [ -n "${S3_SECRET_ACCESS_KEY:-}" ]; then
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
fi

export AWS_DEFAULT_REGION=$S3_REGION
export PGPASSWORD=$POSTGRES_PASSWORD
