FROM python:3

# Create app directory
WORKDIR /app

# Install app dependencies
RUN apt-get update && apt-get install -y cmake > /dev/null
RUN pip install wheel setuptools python-dotenv dlib watchdog people-finder

# Copy app 
COPY . .

# Run the app
CMD ["python","-u","/app/main.py"]
