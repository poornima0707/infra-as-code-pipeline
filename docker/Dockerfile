FROM nginx:latest

RUN sed -i 's/listen       80;/listen       8080;/' /etc/nginx/conf.d/default.conf

RUN printf 'OK' > /usr/share/nginx/html/health
