FROM cloudflare/cloudflared:latest-amd64 AS build

FROM --platform=linux/amd64 alpine:latest

RUN apk --update --no-cache add bind-tools

COPY --from=build /usr/local/bin /usr/local/bin

ENV TUNNEL_METRICS="0.0.0.0:49312" \
  TUNNEL_DNS_ADDRESS="0.0.0.0" \
  TUNNEL_DNS_PORT="5053" \
  IPV4_DNS_ADDRESS_1="1.1.1.3" \
  IPV4_DNS_ADDRESS_2="1.0.0.3" \
  IPV6_DNS_ADDRESS_1="2606:4700:4700::1113" \
  IPV6_DNS_ADDRESS_2="2606:4700:4700::1003" 


ENV TUNNEL_DNS_UPSTREAM="https://$IPV4_DNS_ADDRESS_1/dns-query,https://$IPV4_DNS_ADDRESS_2/dns-query,https://$IPV6_DNS_ADDRESS_1/dns-query,https://$IPV6_DNS_ADDRESS_2/dns-query"

EXPOSE 5053/udp
EXPOSE 49312/tcp

ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["proxy-dns"]

HEALTHCHECK --interval=30s --timeout=20s --start-period=10s \
  CMD dig +short @127.0.0.1 -p $TUNNEL_DNS_PORT cloudflare.com A || exit 1
