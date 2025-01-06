FROM python:3.11

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["uwsgi", "--http", "0.0.0.0:8080", "--wsgi-file", "app/app.py", "--callable", "app"]
