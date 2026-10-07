FROM python:3.12-slim

# Sem .pyc (o filesystem do container é somente leitura no Kubernetes),
# logs sem buffer e HOME em /tmp, o único diretório gravável.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HOME=/tmp

WORKDIR /app

COPY app/requirements.txt .
RUN pip install -r requirements.txt

# Mesmo UID definido em runAsUser no deployment.yaml
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin appuser

COPY --chown=10001:10001 app/app.py .

USER 10001
EXPOSE 8000

# 0.0.0.0 é obrigatório: com 127.0.0.1 o Service e as probes não alcançam o app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
