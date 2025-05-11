ARG CI_COMMIT_TIMESTAMP
ARG CI_COMMIT_SHA
ARG CI_COMMIT_TAG
ARG CI_UPSTREAM_VERSION

# pgvecto.rs binary container
FROM tensorchord/pgvecto-rs-binary:pg16-v0.3.0-${TARGETARCH} as binary

# main container
FROM ghcr.io/cloudnative-pg/postgresql:16.8-14@sha256:ed9bd4a26b152cf35f2c64e15f48126e3477ad222cfb04794562bdc999b8f0be

LABEL org.opencontainers.image.authors="Daniel Muehlbachler-Pietrzykowski <daniel.muehlbachler@niftyside.com>"
LABEL org.opencontainers.image.vendor="Daniel Muehlbachler-Pietrzykowski"
LABEL org.opencontainers.image.source="https://github.com/muhlba91/postgresql-pgvecto-container"
LABEL org.opencontainers.image.created="${CI_COMMIT_TIMESTAMP}"
LABEL org.opencontainers.image.title="postgresql-pgvecto"
LABEL org.opencontainers.image.description="A container integrating pgvecto.rs into CloudNativePG PostgreSQL"
LABEL org.opencontainers.image.revision="${CI_COMMIT_SHA}"
LABEL org.opencontainers.image.version="${CI_COMMIT_TAG}"
LABEL org.opencontainers.image.upstream="${CI_UPSTREAM_VERSION}"

USER root
# taken from https://github.com/tensorchord/pgvecto.rs/
COPY --from=binary /pgvecto-rs-binary-release.deb /tmp/vectors.deb
RUN apt-get install --yes --no-install-recommends /tmp/vectors.deb && rm -f /tmp/vectors.deb
USER 26

CMD ["postgres", "-c" ,"shared_preload_libraries=vectors.so", "-c", "search_path=\"$user\", public, vectors", "-c", "logging_collector=on"]
