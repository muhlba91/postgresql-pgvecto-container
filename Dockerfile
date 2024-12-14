ARG CI_COMMIT_TIMESTAMP
ARG CI_COMMIT_SHA
ARG CI_COMMIT_TAG
ARG CI_UPSTREAM_VERSION

# pgvecto.rs binary container
FROM tensorchord/pgvecto-rs-binary:pg15-v0.2.1-${TARGETARCH} as binary

# main container
FROM ghcr.io/cloudnative-pg/postgresql:15.10-16@sha256:d174f1898e69b8163c4b25f1eabb7583230e762d55b0ad099c53a3895ddf405e

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
