FROM openjdk:8

ENV GOSU_VERSION=1.12 \
    SWARM_VERSION=3.23 \
    MD5=5507abb36d6ca8b01f3416ef21758c9d

RUN apt-get update -y \
  && apt-get -y install --no-install-recommends \
     ca-certificates xvfb=2:1.20.4-1+deb10u1 wget=1.20.1-1.1 python3 python3-pip \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && GPG_KEYS=B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$GPG_KEYS" \
   || gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
   || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" \
   || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEYS" \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN pip3 install setuptools==50.3.2 wheel==0.35.1
RUN pip3 install robotframework==3.2.2 webdrivermanager==0.9.0 robotframework-seleniumlibrary==4.5.0
RUN webdrivermanager chrome firefox opera --linkpath /bin


RUN mkdir -p /var/jenkins_home \
 && useradd -d /var/jenkins_home/worker -u 1000 -m -s /bin/bash jenkins \
 && curl -o /bin/swarm-client.jar -SL https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$SWARM_VERSION/swarm-client-$SWARM_VERSION.jar \
 && echo "$MD5  /bin/swarm-client.jar" | md5sum -c -


COPY docker-entrypoint.sh /

VOLUME /var/jenkins_home/worker
WORKDIR /var/jenkins_home/worker

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java", "-jar", "/bin/swarm-client.jar"]