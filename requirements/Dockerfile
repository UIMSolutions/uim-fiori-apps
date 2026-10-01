FROM debian:bookworm-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		build-essential \
		ldc \
		dub \
		libssl-dev \
	&& rm -rf /var/lib/apt/lists/*

ENV DC=ldc2

WORKDIR /app

COPY backend /app
RUN dub build --compiler=ldc2 --build=release

EXPOSE 8080

CMD ["./project"]
