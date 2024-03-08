# Base image for building CLI tools
FROM debian:stable as base

# Set arguments and install necessary packages
ENV TERRAFORM_VERSION=1.3.9
ENV KUBECTL_VERSION=1.26.0
ENV HELM_VERSION=3.11.2
ENV EKSCLI_VERSION=0.172.0
ENV K9S_VERSION=0.25.4

RUN apt-get update \
    && apt-get install -y curl unzip wget tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Terraform build stage
FROM base as terraform
RUN curl -sSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
    && unzip terraform.zip

# kubectl build stage
FROM base as kubectl
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl

# Helm build stage
FROM base as helm
RUN curl -sSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" -o helm.tar.gz \
    && tar -zxvf helm.tar.gz 

# eksctl build stage
FROM base as eksctl
RUN curl -sSL "https://github.com/weaveworks/eksctl/releases/download/v${EKSCLI_VERSION}/eksctl_Linux_amd64.tar.gz" -o eksctl.tar.gz \
    && tar -zxvf eksctl.tar.gz 


# Final image
FROM debian:stable

# Copy the necessary binaries from previous stages
COPY --from=terraform /terraform /usr/local/bin/terraform
COPY --from=kubectl /kubectl /usr/local/bin/kubectl
COPY --from=helm /linux-amd64/helm /usr/local/bin/helm
COPY --from=eksctl /eksctl /usr/local/bin/eksctl

ARG USERNAME
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

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-amd64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

USER $USERNAME

COPY aliases /tmp/aliases
COPY cluster /usr/local/bin/cluster
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

COPY p10k.zsh /home/$USERNAME/.p10k.zsh
COPY zshrc /home/$USERNAME/.zshrc
WORKDIR /home/$USERNAME

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
