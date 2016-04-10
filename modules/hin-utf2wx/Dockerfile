FROM            ltrc/ilparser-dis-base
COPY            lib /hin-utf2wx/lib
COPY            api.pl /hin-utf2wx/
RUN             pip install /hin-utf2wx/lib/ilparser/hin/utf2wx
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-utf2wx && \
                hypnotoad -f api.pl
