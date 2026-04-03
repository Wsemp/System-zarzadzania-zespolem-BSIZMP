FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# ARG SECRET_KEY
# ARG DEBUG
# ARG ALLOWED_HOSTS

# ENV SECRET_KEY=$SECRET_KEY
# ENV DEBUG=$DEBUG
# ENV ALLOWED_HOSTS=$ALLOWED_HOSTS

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
# RUN python manage.py test

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
