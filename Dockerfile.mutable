FROM chef/ubuntu-14.04:latest

# berks package && docker build -t chef-system-mutable -f Dockerfile.mutable .

COPY .chef/ /etc/chef/

ADD ./cookbooks-*.tar.gz /var/chef/

RUN chef-init --bootstrap
RUN rm -rf /etc/chef/secure/*

CMD ["chef-solo", "-j", "/etc/chef/dna.json"]
