FROM amazon/aws-lambda-python:3.11 AS builder

ENV UV_PYTHON_DOWNLOADS=0

# The installer requires curl (and certificates) to download the release archive
RUN yum install -y tar gzip curl ca-certificates && yum clean all

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

# Sync the project into a new environment, using the frozen lockfile
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev
ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

FROM amazon/aws-lambda-python:3.11

WORKDIR /var/task

# Copy the application from the builder
COPY --from=builder --chown=lambda:lambda /app /var/task

# Place executables in the environment at the front of the path
ENV PATH="/var/task/.venv/bin:$PATH"

CMD ["uv", "run", "lambda_function.py"]