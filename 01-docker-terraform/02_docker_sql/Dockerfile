# From old image to create a new image
FROM python:3.9.1

# What needs to be done for this container
RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2-binary



# Copy files from local machine to destination container
WORKDIR /app
COPY ingest_data.py ingest_data.py
# it will copy the file from local to /app directory in the image

# Overrides
ENTRYPOINT ["python", "ingest_data.py"]