FROM postgis/postgis:13-3.1

# Matches AWS version
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.FeatureSupport.Extensions.13x
ARG PARTMAN_VERSION=v4.5.1

# Install pg_cron
# https://github.com/citusdata/pg_cron
# We need it for parity with AWS RDS
RUN apt-get update \
    && apt-get -y install postgresql-13-cron \
    && rm -rf /var/lib/apt/lists/*

# Install pg_partman
# https://github.com/pgpartman/pg_partman
RUN apt-get update \
    && apt-get install --no-install-recommends -yy git make gcc postgresql-server-dev-13 ca-certificates \
    && git clone --depth 1 --branch ${PARTMAN_VERSION} https://github.com/pgpartman/pg_partman.git /tmp/pg_partman \
    && cd /tmp/pg_partman && make install \
    && cd /tmp && rm -rf pg_partman \
    && apt-get remove --purge -yy git make gcc postgresql-server-dev-13 \
    && rm -rf /var/lib/apt/lists/* \
    && echo "shared_preload_libraries='pg_partman_bgw,pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample
