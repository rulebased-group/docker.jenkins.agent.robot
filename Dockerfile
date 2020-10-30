FROM eeacms/jenkins-slave

USER root

RUN pip install robotframework==3.2.2 webdrivermanager==0.9.0 robotframework-seleniumlibrary==4.5.0

USER ${user}