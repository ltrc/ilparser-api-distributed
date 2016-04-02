FROM            ltrc/ilparser-dis-base
COPY            lib /common-computehead/lib
COPY            api.pl /common-computehead/
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /common-computehead && \
                hypnotoad -f api.pl
