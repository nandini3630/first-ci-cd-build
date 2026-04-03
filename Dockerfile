FROM python:3.12-bookworm AS builder

WORKDIR /app

COPY ./requirements.txt .

RUN pip install -r requirements.txt --target /app/package --no-cache-dir

FROM python:3.12-slim-bookworm As production

WORKDIR /app

ARG GIT_SHA=unknown \
    APP_VERSION=unknown 

LABEL oci.opencontainers.image.version=${APP_VERSION} \
      oci.opencontainers.image.revision=${GIT_SHA}

RUN find / -xdev -perm /6000 -exec chmod a-s {} + 2>/dev/null || true

RUN groupadd -r appusers && \
    useradd -r -s /sbin/bash -g appusers user1 && \
    chown -R user1:appusers /app

COPY --from=builder --chown=user1:appusers /app/package /app/package
COPY --chown=user1:appusers ./main.py .

ENV PYTHONPATH=/app/package

USER user1

CMD ["python","main.py"]
