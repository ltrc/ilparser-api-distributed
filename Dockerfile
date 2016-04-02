FROM            ubuntu
#ENV            HTTP_PROXY      http://proxyuser:proxypwd@proxy.server.com:8080
#ENV            http_proxy      http://proxyuser:proxypwd@proxy.server.com:8080
RUN             apt-get update && apt-get install -y \
                    gcc \
                    make \
                    autoconf \
                    libpq-dev \
                    cpanminus \
                    python-pip \
                    libgdbm-dev \
                    python-numpy \
                    python-pydot \
                    python-urllib3 \
                    libglib2.0-dev \
                    postgresql-9.3 \
                    && rm -rf /var/lib/apt/lists/*
RUN             cpanm \
                    JSON \
                    IPC::Run \
                    Mojo::Pg \
                    Dir::Self \
                    List::Util \
                    Set::Scalar \
                    Data::Dumper \
                    Mojo::Redis2 \
                    String::Random \
                    Graph::Directed \
                    Mojolicious::Lite
USER            postgres
RUN             /etc/init.d/postgresql start && \
                psql --command "CREATE USER ddag WITH SUPERUSER PASSWORD 'nlprocks';" && \
                createdb -O ddag pipelines
USER            root
RUN             locale-gen en_US.UTF-8
ENV             LANG en_US.UTF-8
ENV             LANGUAGE en_US:en
ENV             LC_ALL en_US.UTF-8
