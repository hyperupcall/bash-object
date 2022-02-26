ARG bash_version

FROM bash:${bash_version}

RUN apk add --no-cache git curl \
	&& git config --global user.email "user@example.com" \
	&& git config --global user.name "User Name"

COPY . /opt/bash-object

WORKDIR /opt/bash-object
ENTRYPOINT ["/opt/bash-object/.workflow-data/bats-core/bin/bats"]
