FROM python:3.11-slim

WORKDIR /app

RUN pip install flask

COPY . .

ENV GREETINGS="Hello"

EXPOSE 5000

CMD ["python", "my_app.py"]

