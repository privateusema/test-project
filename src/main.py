from fastapi import FastAPI

app = FastAPI(title="test-project")


@app.get("/")
async def root():
    return {"status": "ok", "project": "test-project"}


@app.get("/health")
async def health():
    return {"healthy": True}
