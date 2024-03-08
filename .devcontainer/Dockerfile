FROM debian:stable

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo python3 python3-pip vim zsh golang lsof ncat wget git unzip curl docker.io openssl \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -aG docker $USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
    
USER $USERNAME

COPY aliases /tmp/aliases
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

COPY p10k.zsh /home/$USERNAME/.p10k.zsh
COPY zshrc /home/$USERNAME/.zshrc
WORKDIR /home/$USERNAME

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
