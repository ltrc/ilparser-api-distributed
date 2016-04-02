FROM            ltrc/ilparser-dis-base
COPY            lib /hin-morph/lib
COPY            api.pl /hin-morph/
RUN             make -C /hin-morph/lib/ilparser/hin/morph/analyser/
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-morph && \
                hypnotoad -f api.pl
