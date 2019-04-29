#! /bin/sh

set -e

if [ "${POSTGRES_DATABASE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ "${GPG_PASSPHRASE}" = "**None**" ]; then
  echo "You need to set the GPG_PASSPHRASE environment variable."
  exit 1
fi

if [ "${AZ_CONTAINER}" = "**None**" ]; then
  echo "You need to set the AZ_CONTAINER environment variable."
  exit 1
fi

if [ "${AZ_ACCOUNT_NAME}" = "**None**" ]; then
  echo "You need to set the AZ_ACCOUNT_NAME environment variable."
  exit 1
fi

if [ "${AZ_ACCOUNT_KEY}" = "**None**" ]; then
  echo "You need to set the AZ_ACCOUNT_KEY environment variable."
  exit 1
fi


# env vars needed for aws tools

export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"

echo "Creating dump of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."

pg_dump $POSTGRES_HOST_OPTS $POSTGRES_DATABASE | gzip | gpg -c --batch --passphrase $GPG_PASSPHRASE -o dump.sql.gz.gpg

echo "Uploading dump to $AZ_CONTAINER"

az storage blob upload --verbose --auth-mode key -f dump.sql.gz.gpg -n ${POSTGRES_HOST}_${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%SZ").sql.gz -c ${AZ_CONTAINER} --account-name ${AZ_ACCOUNT_NAME} --account-key ${AZ_ACCOUNT_KEY} || exit 2

echo "SQL backup uploaded successfully"
