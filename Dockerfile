FROM sv516070.ph.sunlife:8081/sunlife-docker/slf-nodejsbaseimg:latest AS coverage
ARG APP_DIRECTORY_PATH=/app
USER nodeuser
WORKDIR ${APP_DIRECTORY_PATH}
COPY --chown=nodeuser:nodeuser ./package.json ${APP_DIRECTORY_PATH}
COPY --chown=nodeuser:nodeuser . ${APP_DIRECTORY_PATH}
RUN npm ci
RUN npm install -D nyc
RUN npm run test:coverage

FROM sv516070.ph.sunlife:8081/docker-remote/sonarsource/sonar-scanner-cli:latest AS sonarscan
ARG APP_DIRECTORY_PATH=/app
ARG SONARAPP_DIRECTORY_PATH=/usr/src
ARG SONARAPP_PROP_PATH=/opt/sonar-scanner/conf/sonar-scanner.properties
COPY --from=coverage /home/nodeuser/.npmrc /usr/src/.npmrc
COPY  --from=coverage ${APP_DIRECTORY_PATH} ${SONARAPP_DIRECTORY_PATH}
COPY sonar-scanner.properties ${SONARAPP_PROP_PATH}
RUN sonar-scanner

FROM sv516070.ph.sunlife:8081/sunlife-docker/slf-nodejsbaseimg:latest
LABEL com.sunlife.image.owner="API MANAGEMENT"
LABEL com.sunlife.image.allowunapprovedderivation=FALSE
LABEL com.sunlife.image.releasecandidate=FALSE
ARG APP_DIRECTORY_PATH=/app
ARG SONARAPP_DIRECTORY_PATH=/usr/src
USER nodeuser
WORKDIR ${APP_DIRECTORY_PATH}
COPY  --from=sonarscan --chown=nodeuser:nodeuser ${SONARAPP_DIRECTORY_PATH}/package.json ${APP_DIRECTORY_PATH}
RUN npm install
COPY  --from=sonarscan --chown=nodeuser:nodeuser ${SONARAPP_DIRECTORY_PATH}/. ${APP_DIRECTORY_PATH}
RUN ls -la

COPY kubernetes /kubernetes

RUN npm run docker:build \
        && rm -rf ${APP_DIRECTORY_PATH}/src \
            ${APP_DIRECTORY_PATH}/docker-files tsconfig.json

CMD [ "node", "api-builds/server.js" ]
