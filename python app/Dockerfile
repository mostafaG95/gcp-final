FROM python:3.7

COPY . /usr/app

WORKDIR /usr/app

RUN pip install -r requirements.txt

ENV ENVIRONMENT=DEV
ENV HOST=localhost
ENV PORT=8000
ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379
ENV REDIS_DB=0

EXPOSE 8000

CMD ["python3", "hello.py"]