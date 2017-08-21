FROM centos:latest
RUN adduser chapel
RUN yum install -y make gcc gcc-c++ perl which net-tools less openssh openssh-clients openssh-server bzip2 m4 file sudo bind-utils
RUN cd /tmp && curl -L https://github.com/openshift/origin/releases/download/v1.5.1/openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz -o oc.tar.gz && tar xzf oc.tar.gz && mv openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit/oc /usr/local/bin 
RUN echo "chapel ALL=(ALL) !ALL" > /etc/sudoers.d/chapel && echo "chapel ALL=NOPASSWD: /usr/sbin/sshd" >> /etc/sudoers.d/chapel && echo "chapel ALL=NOPASSWD: /usr/bin/tail" >> /etc/sudoers.d/chapel 
RUN chmod 044 /etc/sudoers.d/chapel
RUN cd /home/chapel && curl -L https://github.com/chapel-lang/chapel/releases/download/1.15.0/chapel-1.15.0.tar.gz -o chapel.tar.gz && tar xzf chapel.tar.gz && cd chapel-1.15.0 && source util/quickstart/setchplenv.bash
ENV CHPL_COMM=gasnet
ENV CHPL_LAUNCHER=amudprun

RUN cd /home/chapel/chapel-1.15.0 && make  && export PATH=$PATH:/home/chapel/chapel-1.15.0/bin/linux64 && export CHPL_HOME=/home/chapel/chapel-1.15.0 && export GASNET_SPAWNFN=S && export GASNET_SSH_SERVERS="localhost localhost localhost localhost"
COPY run.sh /home/chapel
RUN chmod +x /home/chapel/run.sh
RUN chown -R chapel.chapel /home/chapel
RUN ssh-keygen -A
RUN sed -i.bak -e "\$aStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" /etc/ssh/ssh_config
RUN sed -i.bak "s/UsePrivilegeSeparation sandbox/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
RUN mkdir /home/chapel/mnt && chmod a+rwx /home/chapel/mnt
USER chapel
RUN ssh-keygen -t rsa -N "" -f /home/chapel/.ssh/id_rsa
RUN cp /home/chapel/.ssh/id_rsa.pub /home/chapel/.ssh/authorized_keys
RUN chmod 600 /home/chapel/.ssh/authorized_keys
ENV CHPL_HOME=/home/chapel/chapel-1.15.0
ENV PATH=$PATH:$CHPL_HOME/bin/linux64
EXPOSE 22
RUN cd $CHPL_HOME && chpl -o /home/chapel/hello6-taskpar-dist $CHPL_HOME/examples/hello6-taskpar-dist.chpl
ENTRYPOINT sudo /usr/sbin/sshd -E /var/log/sshd.log  && sudo tail -f /var/log/sshd.log
