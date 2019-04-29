FROM postgres:11
#forked from https://github.com/schickling/dockerfiles and do some changes
LABEL maintainer="Danil Shulgin <dvshulgin@yandex.ru>"


ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV POSTGRES_DATABASE **None**
ENV POSTGRES_HOST **None**
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER **None**
ENV POSTGRES_PASSWORD **None**
ENV POSTGRES_EXTRA_OPTS ''

ENV AZ_CONTAINER **None**
ENV AZ_ACCOUNT_KEY **None**
ENV AZ_ACCOUNT_NAME **None**
ENV GPG_PASSPHRASE **None**

ADD run.sh run.sh

CMD ["sh", "run.sh"]
