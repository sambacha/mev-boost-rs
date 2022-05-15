# syntax=docker/dockerfile-upstream:master-experimental
FROM rust:1.59.0-slim-bullseye as build

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -qqy --no-install-recommends \
    libssl-dev \
    build-essential \
    dpkg-sig \
    librust-pkg-config-dev \
    openssl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

WORKDIR /opt/mev-boost

ENV CARGO_HOME=/opt/mev-boost/.cargo                       

COPY ./ /mev-boost

# copy over manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

RUN cargo build --release --target x86_64-unknown-linux-gnu

# build for release
RUN rm -rf ./target/release/x86_64-unknown-linux-gnu/deps/
RUN rm -rf ./target/release/x86_64-unknown-linux-gnu/build/

# our final base
# FROM gcr.io/distroless/cc
FROM debian:bullseye-20220418-slim

# Set timezone to UTC by default and configure locales

RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

RUN useradd -ms /bin/bash foundry

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -qqy --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
    
EXPOSE 18550, 8080

# copy the build artifact from the build stage
COPY --chmod=0744 --from=build /opt/mev-boost/target/x86_64-unknown-linux-gnu/release/main /usr/bin/main

CMD ["main"]

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="mev-boost-rs" \
      org.label-schema.description="MEV Boost" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.url="https://github.com/ralexstokes/mev-boost-rs.git/" \
      org.label-schema.vendor="ralexstokes" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
