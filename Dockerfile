FROM node:18-alpine
EXPOSE 8000:8000

# Executing group, with fixed group id
ENV EXECUTING_GROUP fiduswriter
ENV EXECUTING_GROUP_ID 999

# Executing user, with fixed user id
ENV EXECUTING_USER fiduswriter
ENV EXECUTING_USER_ID 999

# Data volume, should be owned by 999:999 to ensure the application can
# function correctly. Run `chown 999:999 <data-dir-path>` on the host OS to
# get this right.
VOLUME ["/data"]

# Create user and group with fixed ID, instead of allowing the OS to pick one.
# RUN addgroup -S --gid ${EXECUTING_GROUP_ID} ${EXECUTING_GROUP} && adduser -G ${EXECUTING_GROUP} --uid ${EXECUTING_USER_ID} -S ${EXECUTING_USER}
RUN addgroup -S ${EXECUTING_GROUP} && adduser -G ${EXECUTING_GROUP} -S ${EXECUTING_USER}

RUN apk add --no-cache python3 py3-pip coreutils
RUN apk add --no-cache --update alpine-sdk jpeg-dev python3-dev gettext zlib-dev git npm

# FidusWriter version
ENV VERSION 3.11.5

RUN pip3 install --upgrade setuptools
RUN pip3 install docutils tzdata fiduswriter[books,languagetool,gitrepo-export]==${VERSION}
RUN pip3 install --upgrade pip wheel

# Working directories should be absolute.
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#workdir
USER ${EXECUTING_USER}
WORKDIR /fiduswriter
RUN mkdir -p static-libs static-transpile
RUN chmod -R 777 /fiduswriter

RUN python3 -m venv venv
RUN source /fiduswriter/venv/bin/activate

COPY start-fiduswriter.sh /etc/start-fiduswriter.sh

# Always use the array form for exec, see
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#cmd
CMD ["/bin/sh", "/etc/start-fiduswriter.sh"]
