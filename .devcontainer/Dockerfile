FROM debian:stable

RUN groupadd --gid 1000 vscode \
    && useradd -s /bin/bash --uid 1000 --gid 1000 -m vscode \
    && apt-get update \
    && apt-get install -y sudo python3 python3-pip vim zsh golang lsof ncat wget git unzip curl docker.io openssl \
    && echo vscode ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && usermod -aG docker vscode \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
    
USER vscode

COPY aliases /tmp/aliases
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

COPY p10k.zsh /home/vscode/.p10k.zsh
COPY zshrc /home/vscode/.zshrc
WORKDIR /home/vscode

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
