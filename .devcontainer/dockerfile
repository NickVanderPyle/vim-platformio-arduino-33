FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get -qq update && \
    apt-get -qqy dist-upgrade && \
    apt-get -qqy --no-install-recommends install \
        apt-utils \
        build-essential \
        ca-certificates \
        curl \
        dialog \
        git \
        sudo \
        unzip \
        wget

RUN if [ ${USER_UID:-0} -ne 0 ] && [ ${USER_GID:-0} -ne 0 ]; then \
        groupadd --gid $USER_GID $USERNAME \
        && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
        && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
        && chmod 0440 /etc/sudoers.d/$USERNAME \
    ; fi

# Install platform.io
RUN apt-get -qqy --no-install-recommends install \
        locales \
        locales-all \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
    && locale-gen en_US.UTF-8 \
    && pip3 install -U platformio
ENV LANG en_US.UTF-8

# Vim
RUN apt-get -qqy --no-install-recommends install vim
#platformio plugin
RUN git clone --recurse-submodules --depth=1 https://github.com/coddingtonbear/neomake-platformio.git /home/$USERNAME/.vim/pack/bundle/start/nomake-platformio
# ccls vim plugin
RUN apt-get -qqy --no-install-recommends install ccls
RUN echo $"\n\
\" Register ccls C++ lanuage server.\n\
if executable('ccls')\n\
   au User lsp_setup call lsp#register_server({\n\
      \\ 'name': 'ccls',\n\
      \\ 'cmd': {server_info->['ccls']},\n\
      \\ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'compile_commands.json'))},\n\
      \\ 'initialization_options': {'cache': {'directory': '/tmp/ccls/cache' }},\n\
      \\ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],\n\
      \\ })\n\
endif\n\
\" Key bindings for vim-lsp.\n\
nn <silent> <M-d> :LspDefinition<cr>\n\
nn <silent> <M-r> :LspReferences<cr>\n\
nn <f2> :LspRename<cr>\n\
nn <silent> <M-a> :LspWorkspaceSymbol<cr>\n\
nn <silent> <M-l> :LspDocumentSymbol<cr>\n\
\n" >> /home/$USERNAME/.vimrc
# arduino syntax highlighting
RUN curl -fLo /home/$USERNAME/.vim/syntax/arduino.vim --create-dirs https://raw.githubusercontent.com/vim-scripts/Arduino-syntax-file/master/syntax/arduino.vim
# You complete me
RUN apt-get -qqy --no-install-recommends install \
        build-essential \
        cmake \
        python3-dev \
    && mkdir -p /home/$USERNAME/.vim/bundle/YouCompleteMe \
    && cd /home/$USERNAME/.vim/bundle/YouCompleteMe \
    && git clone --recurse-submodules --depth=1 https://github.com/ycm-core/YouCompleteMe.git . \
    && python3 install.py --clangd-completer \
    && cd /home/$USERNAME \
    # Place at root so YCM should find it when it looks in all parent directories.
    && curl -fLo /.ycm_extra_conf.py --create-dirs https://gist.githubusercontent.com/ajford/f551b2b6fd4d6b6e1ef2/raw/3bab0d36c667a02877b138219caa6bf7341ce7e1/.ycm_extra_conf.py
# syntactic
RUN git clone --recurse-submodules --depth=1 https://github.com/vim-syntastic/syntastic.git /home/$USERNAME/.vim/bundle/syntastic
RUN echo $"\n\
\" Put these lines at the very end of your vimrc file\n\
\" Load all plugins now.\n\
\" Plugins need to be added before helptags.\n\
packloadall\n\
\" Load all of the helptags for syntastic.\n\
silent! helptags ALL\n\
\n" >> /home/$USERNAME/.vimrc

RUN apt-get -y autoremove && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND interactive

USER $USERNAME
WORKDIR /app