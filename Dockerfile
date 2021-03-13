FROM ruby:2.6.6-buster
ARG BUILD_DATE

ENV ZAMMAD_PORT 80
ENV ZAMMAD_DIR /opt/zammad
ENV ZAMMAD_USER zammad
ENV ZAMMAD_DB zammad
ENV ZAMMAD_DB_USER zammad
ENV ZAMMAD_DB_PASS pass
ENV ZAMMAD_DB_ADAPTER postgresql
ENV ZAMMAD_DB_HOST localhost
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT 1
ENV RAILS_SERVER puma
ENV GIT_URL https://github.com/zammad/zammad.git
ENV GIT_BRANCH develop
ENV ES_SKIP_SET_KERNEL_PARAMETERS true

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Zammad Docker container without database" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="3.x" \
      org.label-schema.docker.cmd="docker run -ti -p $ZAMMAD_PORT:$ZAMMAD_PORT zammad/zammad"

# Expose ports
EXPOSE $ZAMMAD_PORT

# set shell
SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

# fixing service start
RUN printf '#!/bin/bash\nexit 0' > /usr/sbin/policy-rc.d

# install zammad
COPY install-zammad.sh /tmp
RUN chmod +x /tmp/install-zammad.sh;/bin/bash -l -c /tmp/install-zammad.sh

# cleanup
RUN apt-get clean -y && \
    rm -rf preseed.txt /tmp/install-zammad.sh /var/lib/apt/lists/*

# docker init
COPY docker-entrypoint.sh /
RUN chown ${ZAMMAD_USER}:${ZAMMAD_USER} /docker-entrypoint.sh;chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zammad"]
