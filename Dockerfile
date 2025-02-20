FROM ghcr.io/astral-sh/uv:latest AS uv

FROM public.ecr.aws/lambda/python:3.11 AS builder

# Enable bytecode compilation, to improve cold-start performance.
ENV UV_COMPILE_BYTECODE=1

# Disable installer metadata, to create a deterministic layer.
ENV UV_NO_INSTALLER_METADATA=1

# Enable copy mode to support bind mount caching.
ENV UV_LINK_MODE=copy

# Ensure the installed binary is on the `PATH`
# ENV PATH="/root/.local/bin/:$PATH"

# Sync the project into a new environment, using the frozen lockfile
# WORKDIR /app
# ADD . /app
RUN --mount=from=uv,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv export --frozen --no-emit-workspace --no-dev --no-editable -o requirements.txt && \
    uv pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

FROM public.ecr.aws/lambda/python:3.11 AS runtime

# WORKDIR /var/task

# Copy the runtime dependencies from the builder stage.
COPY --from=builder ${LAMBDA_TASK_ROOT} ${LAMBDA_TASK_ROOT}

# Copy the application code.
COPY . ${LAMBDA_TASK_ROOT}/app

CMD ["app.lambda_function.lambda_handler"]