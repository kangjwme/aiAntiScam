FROM python:3.11.13-bookworm AS production

WORKDIR /code

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
  libtiff5-dev

RUN apt install -y \
  gcc \
  g++ \
  musl-dev \
  linux-headers-amd64

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY . /code/

# 方法1：使用相容的 PyTorch 版本
# 先修改 pyproject.toml 中的 torch 版本為 2.5.1 或其他穩定版本
# 然後執行正常的 uv sync
RUN uv sync --frozen --no-cache

# 方法2：如果必須使用 torch 2.7.1，可以這樣做：
# 先安裝 PyTorch (使用 pip)
# RUN pip install torch==2.5.1 --index-url https://download.pytorch.org/whl/cpu
# 然後安裝其他依賴 (排除 torch)
# RUN uv sync --frozen --no-cache --no-install-package torch

# 方法3：使用 CPU 版本的 PyTorch
# RUN pip install torch==2.5.1+cpu --index-url https://download.pytorch.org/whl/cpu
# RUN uv sync --frozen --no-cache --no-install-package torch

EXPOSE 8080

CMD ["/code/.venv/bin/fastapi", "run", "--host", "0.0.0.0", "--port", "8080"]