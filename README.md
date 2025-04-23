# Supervised Collector

An OpenTelemetry Collector distribution which includes the OpAMP supervisor binary in the same container built with [OCB](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder).

## Run the collector

```sh
docker pull honeycombio/supervised-collector:latest
```

```sh
docker run \
  honeycombio/supervised-collector:latest
```
