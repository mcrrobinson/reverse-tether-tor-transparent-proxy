FROM ubuntu:focal

COPY . /src

CMD [ "bash" , "src/install.sh" ]