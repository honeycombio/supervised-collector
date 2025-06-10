FROM golang:1.24 AS build
WORKDIR /go/src

ADD ./builder-config.yaml ./
RUN go install go.opentelemetry.io/collector/cmd/builder@v0.127.0
RUN builder --config builder-config.yaml

# use the official upstream image for the opampsupervisor
FROM ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-opampsupervisor AS opampsupervisor

FROM busybox:stable AS busybox

FROM honeycombio/honeycomb-opentelemetry-collector:latest
# Copy in some stuff so we can shell and look around
COPY --from=busybox /bin/sh /bin/sh
COPY --from=busybox /bin/cat /bin/cat
COPY --from=busybox /bin/ls /bin/ls

ARG USER_UID=10001
ARG USER_GID=10001
USER ${USER_UID}:${USER_GID}

COPY --from=opampsupervisor --chmod=755 /usr/local/bin/opampsupervisor /opampsupervisor
COPY --from=build --chmod=755 /go/src/supervised-collector/supervised-collector /honeycomb-otelcol

WORKDIR /var/lib/otelcol/supervisor
ENTRYPOINT ["/opampsupervisor"]
