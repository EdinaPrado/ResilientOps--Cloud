import random
import time

from fastapi import FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="ResilientOps API")

# Métricas Prometheus em /metrics (requisições, latência, status HTTP).
# /healthz e /metrics ficam fora para não poluir os dados com tráfego das probes.
Instrumentator(excluded_handlers=["/healthz", "/metrics"]).instrument(app).expose(
    app, include_in_schema=False
)


@app.get("/")
def read_root():
    # Simula uma latência normal de produção (entre 10ms e 50ms)
    time.sleep(random.uniform(0.01, 0.05))
    return {"status": "healthy", "message": "ResilientOps API operando normalmente"}


@app.get("/heavy")
def heavy_load():
    # Simula um processamento pesado para consumir CPU (200ms por requisição)
    start_time = time.perf_counter()
    count = 0
    while time.perf_counter() - start_time < 0.2:
        count += 1
    return {"status": "computed", "iterations": count}


@app.get("/error")
def trigger_error():
    # Simula uma falha interna (Erro 500) para testar a monitoração
    raise HTTPException(status_code=500, detail="Erro interno simulado no servidor")


# "async def" roda direto no event loop, sem disputar vaga na threadpool
# com /heavy. Assim, mesmo sob carga, as probes do Kubernetes continuam
# respondendo e o pod não é reiniciado à toa.
@app.get("/healthz")
async def health_check():
    return {"status": "OK"}