# main container
FROM ghcr.io/cloudnative-pg/postgresql:18.1-standard-bookworm@sha256:5672ea4c8cb782628c77631d6b44c73694f898eec4e4ff6dc34638790132ed17

ARG CI_COMMIT_TIMESTAMP
ARG CI_COMMIT_SHA
ARG CI_COMMIT_TAG
ARG CI_UPSTREAM_VERSION
ARG POSTGRESQL_MAJOR_VERSION=18
ARG VCHORD_VERSION=0.5.3

LABEL org.opencontainers.image.authors="Daniel Muehlbachler-Pietrzykowski <daniel.muehlbachler@niftyside.com>"
LABEL org.opencontainers.image.vendor="Daniel Muehlbachler-Pietrzykowski"
LABEL org.opencontainers.image.source="https://github.com/muhlba91/postgresql-pgvecto-container"
LABEL org.opencontainers.image.created="${CI_COMMIT_TIMESTAMP}"
LABEL org.opencontainers.image.title="cloudnativepg-postgresql-vectorchord"
LABEL org.opencontainers.image.description="A container integrating VectorChord into CloudNativePG PostgreSQL"
LABEL org.opencontainers.image.revision="${CI_COMMIT_SHA}"
LABEL org.opencontainers.image.version="${CI_COMMIT_TAG}"
LABEL org.opencontainers.image.upstream="${CI_UPSTREAM_VERSION}"

# use root to install binaries
USER root

# taken from: https://github.com/tensorchord/VectorChord-images
# hadolint ignore=DL3008,DL3015,SC2046
RUN apt-get update && \
  apt-get install -y --no-install-recommends wget ca-certificates && \
  wget -q https://github.com/tensorchord/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-${POSTGRESQL_MAJOR_VERSION}-vchord_${VCHORD_VERSION}-1_$(dpkg --print-architecture).deb -P /tmp && \
  apt-get install -y /tmp/postgresql-${POSTGRESQL_MAJOR_VERSION}-vchord_${VCHORD_VERSION}-1_$(dpkg --print-architecture).deb && \
  apt-get remove -y wget ca-certificates && \
  apt-get purge -y --auto-remove && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# set user back to postgres
USER 26

CMD ["postgres", "-c" ,"shared_preload_libraries=vchord.so"]
