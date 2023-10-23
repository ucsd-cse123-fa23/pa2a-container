FROM ubuntu:18.04 as linux

RUN apt update && \
	apt install -y openvswitch-switch mininet iproute2 \
                curl inetutils-ping inetutils-traceroute \
                build-essential git nano screen python python-pip sudo && \
        pip install typing && \
        pip install mininet twisted ltprotocol

RUN apt install -y python3 python3-pip && \
        pip3 install -U pip && \
	pip3 install -U cryptography && \
        pip3 install mininet pexpect scapy

WORKDIR /

COPY project-base project-base

FROM --platform=linux/amd64 linux as windows

RUN apt update && \
	apt install -y build-essential flex bison libssl-dev libelf-dev git dwarves bc python3

RUN git clone https://github.com/microsoft/WSL2-Linux-Kernel.git /wsl-kernel
COPY windows-configs/.config /wsl-kernel/.config
RUN yes "" | make -C /wsl-kernel -j $(expr $(nproc) - 1)
RUN yes "" | make -C /wsl-kernel -j $(expr $(nproc) - 1) modules
RUN make -C /wsl-kernel modules_install
