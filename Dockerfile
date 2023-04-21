FROM docker.tools.post.ch/base/adoptjre:latest-17 as builder
USER root
WORKDIR application
COPY dopla-core-app/target/*.jar application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM docker.tools.post.ch/base/adoptjre:latest-17
LABEL ch.post.it.description        = "dopla-core"
LABEL ch.post.it.maintainer.email   = "24f17e9d.o365groups.post.ch@ch.teams.ms"
LABEL ch.post.it.notification.email = "24f17e9d.o365groups.post.ch@ch.teams.ms"
LABEL ch.post.it.app.name           = "dopla-core"
LABEL ch.post.it.app.version        = "$IMAGE_TAG"
LABEL ch.post.it.project.shortname  = "dopla"
WORKDIR /usr/local/app/
USER baseuser

#COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
#COPY --from=builder application/snapshot-dependencies/ ./
#COPY --from=builder application/application/ ./
COPY dopla-core-app/src/main/resources/certs/isvcm-client-truststore.jks /usr/local/app/certs/isvcm-client-truststore.jks


ENTRYPOINT [ "java", "org.springframework.boot.loader.JarLauncher", "--spring.profiles.active=${SYSTEM_ENV}" ]
