FROM exadel/compreface-core:1.1.0-arcface-r100-gpu
ENV PGDATA=/data/database
RUN apt-get update && apt-get install jq -y && rm -rf /var/lib/apt/lists/*
COPY postgresql.conf /etc/postgresql/13/main/postgresql.conf
COPY run.sh /
CMD ["/run.sh"]

