FROM ppodgorsek/robot-framework:latest as robot
FROM openjdk:alpine
COPY --from=robot / /

ENV JENKINS_DIR /opt/jenkins
ENV JENKINS_HOME_DIR ${JENKINS_DIR}/home
ENV JENKINS_HOME_GIT_REPO ${JENKINS_HOME_DIR}/gitrepo

ENV JENKINS_UID 1000
ENV JENKINS_GID 1000

# Dependency versions
ENV SWARM_CLIENT_VERSION="3.9"

# Create the default report and work folders with the default user to avoid runtime issues
# These folders are writeable by anyone, to ensure the user can be changed on the command line.
RUN mkdir -p ${JENKINS_HOME_GIT_REPO} \
  && chown -R ${JENKINS_UID}:${JENKINS_GID} ${JENKINS_DIR} \
  && chmod ugo+w ${JENKINS_HOME_DIR} ${JENKINS_HOME_GIT_REPO}

# Install system dependencies
RUN apk --no-cache add git \
  && apk --no-cache --virtual .build-deps add \
     wget \
# download swarm-agent
  && wget -q https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_CLIENT_VERSION}/swarm-client-${SWARM_CLIENT_VERSION}.jar -O ${JENKINS_DIR}/swarm-client.jar \
# cleanup
  && apk del --no-cache --update-cache .build-deps

# Allow any user to write logs
RUN chmod ugo+w /var/log \
  && chown ${JENKINS_UID}:${JENKINS_GID} /var/log

USER 1000:1000

ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

COPY --chown=1000:1000 bin/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# A dedicated work folder to allow for the creation of temporary files
WORKDIR ${JENKINS_HOME_DIR}

ENTRYPOINT "/docker-entrypoint.sh"