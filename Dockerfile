FROM python:3.11-bookworm AS production

WORKDIR /code

# 安裝系統依賴
RUN apt update && apt install -y \
  curl \
  git \
  build-essential \
  libffi-dev \
  libssl-dev \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  zlib1g-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libwebp-dev \
  libopenjp2-7-dev \
  libtiff5-dev \
  gcc \
  g++ \
  && rm -rf /var/lib/apt/lists/*

# 安裝 uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 複製項目文件
COPY . /code/

# 安裝 Python 依賴（使用 CPU 版本的 PyTorch）
RUN uv sync --frozen --no-cache

EXPOSE 8000

# 修正 FastAPI 命令，指定主文件
CMD ["/code/.venv/bin/fastapi", "run", "main.py", "--host", "0.0.0.0", "--port", "8000"]