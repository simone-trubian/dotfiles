# Add virtualenv fish wrapper
eval (python -m virtualfish)

# Add Go binaries to the path
if test -d /usr/local/go
  set -x PATH /usr/local/go/bin $PATH
end

# Add Go workspace binaries to the path
if test -d $HOME/go
  set -x PATH $HOME/go/bin $PATH
end

# Add Go workspace to the path
if test -d $HOME/go
  set -x GOPATH $HOME/go
end

# Add Java 8 binaries to the path
if test -d /usr/lib/jvm/java-8-oracle
  set -x JAVA_HOME /usr/lib/jvm/java-8-oracle
end

# Add Rust binaries to the path
if test -d $HOME/.cargo/bin/
  set -x PATH $HOME/.cargo/bin/ $PATH
end

# Add Rust toolchain sources
if test -d $HOME/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/
  set -x RUST_SRC_PATH $HOME/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/
end

# Add Protoc protobuf compiler
if test -d /usr/local/protoc
    set -x PATH /usr/local/protoc/bin $PATH
end

# Add Python Poetry to the path
if test -d $HOME/.poetry/bin/
  set -x PATH $HOME/.poetry/bin/ $PATH
end

# Set custom ls colours
set -x LS_COLORS "rs=0:di=00;34:ln=00;105:mh=00:pi=40;91:so=00;35:do=00;35:bd=40;91;00:cd=40;91;00:or=40;31;00:su=37;41:sg=30;43:ca=30;41:tw=30;102:ow=34;102:st=37;44:ex=00;32:*.tar=00;31:*.tgz=00;31:*.arc=00;31:*.arj=00;31:*.taz=00;31:*.lha=00;31:*.lz4=00;31:*.lzh=00;31:*.lzma=00;31:*.tlz=00;31:*.txz=00;31:*.tzo=00;31:*.t7z=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.dz=00;31:*.gz=00;31:*.lrz=00;31:*.lz=00;31:*.lzo=00;31:*.xz=00;31:*.bz2=00;31:*.bz=00;31:*.tbz=00;31:*.tbz2=00;31:*.tz=00;31:*.deb=00;31:*.rpm=00;31:*.jar=00;31:*.war=00;31:*.ear=00;31:*.sar=00;31:*.rar=00;31:*.alz=00;31:*.ace=00;31:*.zoo=00;31:*.cpio=00;31:*.7z=00;31:*.rz=00;31:*.cab=00;31:*.jpg=00;35:*.jpeg=00;35:*.gif=00;35:*.bmp=00;35:*.pbm=00;35:*.pgm=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.tiff=00;35:*.png=00;35:*.svg=00;35:*.svgz=00;35:*.mng=00;35:*.pcx=00;35:*.mov=00;35:*.mpg=00;35:*.mpeg=00;35:*.m2v=00;35:*.mkv=00;35:*.webm=00;35:*.ogm=00;35:*.mp4=00;35:*.m4v=00;35:*.mp4v=00;35:*.vob=00;35:*.qt=00;35:*.nuv=00;35:*.wmv=00;35:*.asf=00;35:*.rm=00;35:*.rmvb=00;35:*.flc=00;35:*.avi=00;35:*.fli=00;35:*.flv=00;35:*.gl=00;35:*.dl=00;35:*.xcf=00;35:*.xwd=00;35:*.yuv=00;35:*.cgm=00;35:*.emf=00;35:*.axv=00;35:*.anx=00;35:*.ogv=00;35:*.ogx=00;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:*.py=00;95:*.markdown=00;95:*.md=00;95:*.hs=00;95:*.sh=00;95:*.java=00;95:*.scala=00;95:*.jl=00;95:*.clo=00;95:*.html=00;95:*.xml=00;95:*.vim=00;95:"

# Add Opam configuration
if test -d $HOME/.opam/
  source /home/simone/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
end
