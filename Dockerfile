ARG GITHUB_REPO=github.com/sapcc/snmp_exporter

FROM keppel.eu-de-1.cloud.sap/ccloud/golang-alpine:1.16 as builder
ARG GITHUB_REPO
ENV GITHUB_REPO=$GITHUB_REPO
WORKDIR /go/src/$GITHUB_REPO/
COPY ./ .
RUN go build -o .build/linux-amd64/snmp_exporter

################################################################################

FROM quay.io/prometheus/busybox-linux-amd64:latest as packer
ARG GITHUB_REPO
ENV GITHUB_REPO=$GITHUB_REPO
LABEL source_repository="https://$GITHUB_REPO"
WORKDIR /bin
COPY --from=builder /go/src/$GITHUB_REPO/.build/linux-amd64/snmp_exporter /bin/snmp_exporter
COPY snmp.yml       /etc/snmp_exporter/snmp.yml
EXPOSE      9116
ENTRYPOINT  [ "/bin/snmp_exporter" ]
CMD         [ "--config.file=/etc/snmp_exporter/snmp.yml" ]