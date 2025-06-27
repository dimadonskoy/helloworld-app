FROM python:3.12-alpine

WORKDIR /app
COPY ./src/helloworld-app/app.py .

RUN pip install --no-cache-dir flask

EXPOSE 8090

CMD ["python", "app.py"] 