FROM centos:centos8.4.2105

RUN sed -i -e 's/^enabled\s*=\s*1/enabled = 0/g' \
  /etc/yum.repos.d/CentOS-Linux-Extras.repo && \
  sed -i -e 's/^mirrorlist=\(.*\)$/#mirrorlist=\1/g' \
  -e 's|^#baseurl=http://mirror.centos.org\(.*\)$|baseurl=https://vault.centos.org\1|g' \
  /etc/yum.repos.d/CentOS-Linux-BaseOS.repo \
  /etc/yum.repos.d/CentOS-Linux-AppStream.repo

RUN dnf -y install sudo openssh-clients openssh-server && \
  systemctl enable sshd

CMD ["/sbin/init"]
