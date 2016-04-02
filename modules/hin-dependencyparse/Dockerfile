FROM            ltrc/ilparser-dis-base
COPY            lib /hin-dependencyparse/lib
COPY            api.pl /hin-dependencyparse/
RUN             pip install /hin-dependencyparse/lib/ilparser/hin/dependencyparse
RUN             pip install /hin-dependencyparse/lib/ilparser/hin/indic-wx-converter
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-dependencyparse && \
                hypnotoad -f api.pl
