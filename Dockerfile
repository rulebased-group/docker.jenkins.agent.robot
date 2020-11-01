FROM eeacms/jenkins-slave:3.23

USER root

RUN apt-get update -y \
    && apt-get -y install --no-install-recommends \
    xvfb=2:1.20.4-1+deb10u1 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN pip install robotframework==3.2.2 webdrivermanager==0.9.0 robotframework-seleniumlibrary==4.5.0

USER ${user}