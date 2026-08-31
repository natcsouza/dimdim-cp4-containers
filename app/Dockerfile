# ---------- Etapa 1: build ----------
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests


# ---------- Etapa 2: runtime ----------
FROM eclipse-temurin:17-jre-alpine

# O container do App NAO pode rodar como root (regra do checkpoint).
RUN addgroup -S dimdim && adduser -S dimdim -G dimdim

WORKDIR /app

COPY --from=build /build/target/dimdim-1.0.0.jar app.jar

RUN chown -R dimdim:dimdim /app

USER dimdim

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
