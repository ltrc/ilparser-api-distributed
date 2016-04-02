FROM            ltrc/ilparser-dis-base
COPY            lib /hin-guessmorph/lib
COPY            api.pl /hin-guessmorph/
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-guessmorph && \
                hypnotoad -f api.pl
