FROM            ltrc/ilparser-dis-base
COPY            lib /hin-pruning/lib
COPY            api.pl /hin-pruning/
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-pruning && \
                hypnotoad -f api.pl
