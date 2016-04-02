FROM            ltrc/ilparser-dis-base
COPY            lib /common-computevibhakti/lib
COPY            api.pl /common-computevibhakti/
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /common-computevibhakti && \
                hypnotoad -f api.pl
