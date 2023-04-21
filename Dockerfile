FROM docker.tools.post.ch/base/jre:17-buster-slim as builder
USER root
WORKDIR application
COPY target/*.jar application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM docker.tools.post.ch/base/jre:17-buster-slim
# ENV _JAVA_OPTIONS "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
WORKDIR /usr/local/app/
USER baseuser

COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
#COPY dopla-core-app/src/main/resources/certs/isvcm-client-truststore.jks /usr/local/app/certs/isvcm-client-truststore.jks


ENTRYPOINT [ "java", "org.springframework.boot.loader.JarLauncher"]
