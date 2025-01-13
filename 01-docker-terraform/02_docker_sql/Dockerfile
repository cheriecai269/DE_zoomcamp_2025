# From old image to create a new image
FROM python:3.9.1

# What needs to be done for this container
RUN pip install pandas

# Copy files from local machine to destination container
WORKDIR /app
COPY pipeline.py pipeline.py
# it will copy the file from local to /app directory in the image

# Overrides
ENTRYPOINT ["python", "pipeline.py"]