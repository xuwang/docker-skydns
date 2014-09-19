FROM google/golang:1.3.1

# Install docker.io, 
# necessary only when host os is not same as the base iamge i.e. Debian GNU/Linux 7 (wheezy)

ENV DEBIAN_FRONTEND noninteractive
RUN echo 'deb http://http.debian.net/debian wheezy-backports main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y -t wheezy-backports linux-image-amd64 \
    && curl -sSL https://get.docker.io/ | sh

# Build static linked skydns binary
RUN CGO_ENABLED=0 go get -a -ldflags '-s' github.com/skynetservices/skydns

# Build a skydns binary only docker image
ADD Dockerfile.skydns /gopath/Dockerfile
CMD tag=$(cd ${GOPATH}/src/github.com/skynetservices/skydns; git rev-parse --short=12 HEAD) \
    && docker build -t skydns:$tag gopath \
    && docker tag skydns:$tag skydns:latest 