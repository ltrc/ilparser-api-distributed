FROM            ltrc/ilparser-dis-base
COPY            lib /hin-wx2utf/lib
COPY            api.pl /hin-wx2utf/
RUN             pip install /hin-wx2utf/lib/ilparser/hin/wx2utf
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-wx2utf && \
                hypnotoad -f api.pl
