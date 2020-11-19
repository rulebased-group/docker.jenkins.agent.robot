FROM ppodgorsek/robot-framework:latest

FROM eeacms/jenkins-slave:latest
COPY --from=0 / .