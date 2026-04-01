FROM python:3.12-bookworm AS builder

WORKDIR /app

COPY ./requirements.txt .

RUN pip install -r requirements.txt \
    --no-cache-dir \
    --target /app/package

# -------------------------------------------------------
FROM python:3.12-slim-bookworm AS production

ARG GITHUB_SHA=unknown \
APP_VERSION=unknown

LABEL oci.opencontainers.image.version=${APP_VERSION} \
      oci.opencontainers.image.revision=${GITHUB_SHA}

WORKDIR /app

RUN find / -xdev -perm /6000 -exec chmod a-s {} + 2>/dev/null || true

RUN groupadd -r appusers && \
    useradd -r -s /sbin/nologin -g appusers rajpal && \
    chown -R rajpal:appusers /app

COPY --from=builder --chown=rajpal:appusers /app/package /app/package
COPY --chown=rajpal:appusers ./main.py .

ENV PYTHONPATH=/app/package

EXPOSE 5000

USER rajpal

CMD ["python","main.py"]
