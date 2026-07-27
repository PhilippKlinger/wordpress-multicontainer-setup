ARG BASE_IMAGE=alpine:TODO_VERSION
FROM ${BASE_IMAGE}

ARG CONTAINER_PORT=TODO_CONTAINER_PORT

ENV APP_NAME=devsecops-app \
    DATA_DIR=/data

WORKDIR /app

# Add dependency installation and selective COPY instructions for the project.
COPY . .
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE ${CONTAINER_PORT}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Replace this placeholder with the project-specific start command.
CMD ["TODO_START_COMMAND"]
