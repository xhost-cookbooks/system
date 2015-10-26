FROM chef/ubuntu-14.04:latest

# berks package && docker build -t chef-system .

COPY .chef/ /etc/chef/

ADD ./cookbooks-*.tar.gz /var/chef/

RUN chef-init --bootstrap
RUN rm -rf /etc/chef/secure/*

ENTRYPOINT ["chef-init"]

CMD ["--onboot"]
