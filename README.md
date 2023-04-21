# Spring Boot Test project

## Initialization

- Created with [Spring Initializer](https://start.spring.io/)
  - Default with **Spring Web** dependency

## Build and run

- `./runTool.cmd mvn clean install`
- `./runTool.cmd mvn spring-boot:run`
  - Access at <http://localhost:8080>

## Docker build

- Build app: `./runTool.cmd mvn clean install -DskipTests`
- Build image: `docker build -t test/spring-boot-306 .`
- Run: `docker run -d -p 8080:8080 --rm --name test-spring-boot-306 -e SYSTEM_ENV=dev test/spring-boot-306`
