# Extend the GNU parallel image and add Python 3 for running the CSV processing script
FROM alhumaidyaroob/gnu-parallel:latest

SHELL ["/bin/bash", "-c"]

# Install Python 3 (and pip just in case). If the base is Debian/Ubuntu this works.
# If your base were Alpine, swap to: apk add --no-cache python3 py3-pip
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
ENV PYTHONUNBUFFERED=1

# Default to interactive shell; we'll override CMD in docker run when needed
CMD ["/bin/bash"]
