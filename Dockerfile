# DOCKER-VERSION 1.2.0
# VERSION 0.1

FROM postgres:9.3.5
MAINTAINER James Badger <james@jamesbadger.ca>

ENV DEBIAN_FRONTEND noninteractive
ENV PG_MAJOR 9.3

RUN apt-get update && apt-get install -y -q postgresql-${PG_MAJOR}-postgis-2.1 postgresql-contrib postgresql-server-dev-${PG_MAJOR}

COPY ./postgres-entry.sh /
ENTRYPOINT ["/postgres-entry.sh"]

EXPOSE 5432
CMD ["postgres"]
