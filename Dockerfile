FROM python:2.7.14-alpine3.7

WORKDIR /usr/src/egress

COPY requirements.txt ./
RUN  pip install --no-cache-dir -r requirements.txt

COPY egress/ ./

ENTRYPOINT ["python"]

CMD ["egress.py"]
