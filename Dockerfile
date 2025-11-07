FROM golang:1.24 AS build
WORKDIR /go/src

ADD ./builder-config.yaml ./
RUN go install go.opentelemetry.io/collector/cmd/builder@v0.139.0
RUN builder --config builder-config.yaml

# use the official upstream image for the opampsupervisor
FROM ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-opampsupervisor:0.139.0 AS opampsupervisor

FROM honeycombio/honeycomb-opentelemetry-collector:v0.0.22

ARG USER_UID=10001
ARG USER_GID=10001
USER ${USER_UID}:${USER_GID}

COPY --from=opampsupervisor --chmod=755 /usr/local/bin/opampsupervisor /opampsupervisor
COPY --from=build --chmod=755 /go/src/supervised-collector/supervised-collector /honeycomb-otelcol
COPY ./config/agent.yaml /etc/agent.yaml
COPY ./config/opampsupervisor.yaml /etc/opampsupervisor.yaml

WORKDIR /var/lib/otelcol/supervisor
ENTRYPOINT ["/opampsupervisor"]
