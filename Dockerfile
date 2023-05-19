# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.11

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

# Install production dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Install curl
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl

# Download, unpack, make the Pixlet binary executable and move it into PATH. Update version number when necessary
RUN curl -LO https://github.com/tidbyt/pixlet/releases/download/v0.22.4/pixlet_0.22.4_linux_amd64.tar.gz && \
    tar -xvf pixlet_0.22.4_linux_amd64.tar.gz && \
    chmod +x ./pixlet && \
    mv pixlet /usr/local/bin/pixlet

COPY sample.star /sample1.star
COPY sample.star /sample2.star

# Expose port 8080 for Cloud Run
EXPOSE 8080

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
