FROM python:3.12-bookworm AS builder

WORKDIR /app

COPY ./requirements.txt .

RUN pip install requirements.txt \
    --no-cache-dir \
    --target /app/package

-------------------------------------------------------
FROM python:3.12-slim-bookworm AS production

ARG
GITHUB_SHA=unknown
APP_VERSION=unknown

LABEL oci.opencontainers.image.version=${APP_VERSION} \
      oci.opencontainers.image.revision=${GITHUB_SHA}

WORKDIR /app

RUN find / -xdev -perm /6000 -exec chmod a-s {} + 2>/dev/null || true

RUN groupadd -r users \
    useradd -r -s /sbin/nologin -g users rajpal \
    chown -R rajpal:users /app

COPY --from=builder --chown rajpal:users /app/package
     --chown rajpal:users ./main.py .

PYTHONPATH=/app/package

EXPOSE 5000

USER rajpal

CMD ["python","main.py"]