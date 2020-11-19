FROM ppodgorsek/robot-framework:3.7.0 as robotFramework

FROM eeacms/jenkins-slave:3.23
COPY --from=robotFramework / .