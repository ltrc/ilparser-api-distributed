FROM            ltrc/ilparser-dis-base
COPY            lib /common-pickonemorph/lib
COPY            api.pl /common-pickonemorph/
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /common-pickonemorph && \
                hypnotoad -f api.pl
