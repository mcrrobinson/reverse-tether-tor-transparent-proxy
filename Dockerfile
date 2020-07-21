FROM ubuntu:focal

COPY . /src

CMD [ "bash", "install.sh" ]