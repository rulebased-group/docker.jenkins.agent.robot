FROM eeacms/jenkins-slave

USER root

RUN pip install robotframework webdrivermanager robotframework-seleniumlibrary

USER ${user}