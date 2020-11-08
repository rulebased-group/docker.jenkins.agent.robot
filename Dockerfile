FROM openjdk:8

ENV GOSU_VERSION=1.12 \
    SWARM_VERSION=3.23 \
    MD5=5507abb36d6ca8b01f3416ef21758c9d

# hadolint ignore=DL4001
RUN apt-get update -y \
  && apt-get -y install --no-install-recommends \
     ca-certificates=20200601~deb10u1 xvfb=2:1.20.4-1+deb10u1 wget=1.20.1-1.1 python3.7=3.7.3-2+deb10u2 python3-pip=18.1-5 \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && GNUPGHOME="$(mktemp -d)" \
  && export GNUPGHOME \
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

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL4001
RUN mkdir -p /var/jenkins_home \
 && useradd -d /var/jenkins_home/worker -u 1000 -m -s /bin/bash jenkins \
 && curl -o /bin/swarm-client.jar -SL https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$SWARM_VERSION/swarm-client-$SWARM_VERSION.jar \
 && echo "$MD5  /bin/swarm-client.jar" | md5sum -c -


# hadolint ignore=DL4001
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get -y --no-install-recommends install google-chrome-stable=86.0.4240.183-1 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY docker-entrypoint.sh /

VOLUME /var/jenkins_home/worker
WORKDIR /var/jenkins_home/worker

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java", "-jar", "/bin/swarm-client.jar"]