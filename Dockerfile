FROM python:3.13.16-slim-trixie@sha256:6906dca82c0e83d5994bbf2e7fc33e6b63ce3e7f27c30eafd01dfabeb3c90bf3 AS base

FROM base AS builder

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY --from=builder /install /usr/local
COPY app.py .

RUN useradd --create-home appuser
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/status', timeout=2)"]

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
