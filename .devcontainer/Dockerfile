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
# NodeJS required for coc.nvim
RUN apt-get -qqy --no-install-recommends install vim nodejs npm yarn

# Switching user from root. No more apt-get after this.
RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -Rf /var/lib/apt/lists/*

# Vim-plug needs the .vim directory to be owned by executing user.
USER $USERNAME
RUN mkdir -p /home/$USERNAME/.vim/autoload

#vim-plug
RUN echo "\
\" vim-plug auto install.\n\
if empty(glob('~/.vim/autoload/plug.vim'))\n\
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs\n\
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim\n\
  autocmd VimEnter * PlugInstall --sync | source \$MYVIMRC\n\
endif\n\
\n\
\n\ 
\" Begin VIM plugin section in vimrc\n\
call plug#begin('~/.vim/plugged')\n\
\" https://github.com/junegunn/fzf.vim#installation \n\
Plug 'junegunn/fzf', { 'do': './install --bin' } \n\
Plug 'junegunn/fzf.vim'\n\
\" https://github.com/neoclide/coc.nvim#quick-start \n\
Plug 'neoclide/coc.nvim', {'branch': 'release'} \n\
\" https://github.com/preservim/nerdtree#vim-plug \n\
Plug 'preservim/nerdtree'\n\
\" https://github.com/ryanoasis/vim-devicons#installation \n\
Plug 'ryanoasis/vim-devicons'\n\
\" https://github.com/coddingtonbear/neomake-platformio \n\
Plug 'coddingtonbear/neomake-platformio'\n\
call plug#end()\n\
\n" >> /home/$USERNAME/.vimrc

RUN echo "\
\" Some defaults.\n\
\" Turn on the mouse in vim!?\n\
set mouse=n\n\
set ttymouse=xterm2\n\
set encoding=UTF-8\n\
\" Turn on syntax highlighting.\n\
syntax on\n\
\" Turn on line numbering.\n\
set number\n\
\" Open NERDTree when vim opens.\n\
autocmd vimenter * NERDTree\n\
\" Close NERDTree if it's the last window open.\n\
autocmd bufenter * if (winnr(\"\$\") == 1 && exists(\"b:NERDTree\") && b:NERDTree.isTabTree()) | q | endif\n\
\n" >> /home/$USERNAME/.vimrc

# Configuration for coc.nvim. Setup clangd as language server.
RUN echo '\n\
{\n\
  "languageserver": {\n\
    "clangd": {\n\
      "command": "clangd",\n\
      "args": ["--background-index"],\n\
      "rootPatterns": ["compile_flags.txt", "compile_commands.json", ".git/", ".hg/"],\n\
      "filetypes": ["c", "cpp", "objc", "objcpp"]\n\
    }\n\
  }\n\
}\n\
\n' >> /home/$USERNAME/.vim/coc-settings.json

# arduino syntax highlighting
RUN curl -fLo /home/$USERNAME/.vim/syntax/arduino.vim --create-dirs https://raw.githubusercontent.com/vim-scripts/Arduino-syntax-file/master/syntax/arduino.vim

ENV DEBIAN_FRONTEND interactive

USER $USERNAME
WORKDIR /app