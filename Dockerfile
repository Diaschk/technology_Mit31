FROM python:3

WORKDIR /app

ADD app.py /app/

RUN pip install flask flask_restful

EXPOSE 8083

CMD ["python", "app.py"]
