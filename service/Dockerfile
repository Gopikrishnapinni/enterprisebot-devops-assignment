FROM python:3.12.7-slim-bookworm AS builder

WORKDIR /build
COPY requirements.txt .
RUN python -m pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12.7-slim-bookworm

RUN groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid 10001 --no-create-home app
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .
USER 10001:10001
EXPOSE 8080
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
CMD ["python", "app.py"]
