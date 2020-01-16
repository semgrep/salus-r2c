FROM ocaml/opam2:debian-9@sha256:17758086f5408f628cadb06ba1ec4dd929d8a46c0e7edc8243a3105f2859215a as build
USER root
RUN apt-get install perl m4 pkg-config -y
USER opam
WORKDIR /home/opam/opam-repository
RUN git pull && \
  opam update && opam switch 4.07 && \
  opam install ocamlfind camlp4 num ocamlgraph json-wheel conf-perl && \
  opam install dune yaml
WORKDIR /home/opam/

RUN git clone https://github.com/returntocorp/pfff
RUN eval $(opam env); cd pfff; git checkout 8617db4c617772e727b050e285d38b30f8f07a79; ./configure; \
    make depend && make && make opt && \
    make install-libs

RUN git clone https://github.com/returntocorp/sgrep
RUN eval $(opam env); cd sgrep; git checkout 0857759e2666bfb974ba93dceb2cc0a82f373bdd; \
    dune build

FROM coinbase/salus@sha256:548d4e9e57cd8b8680879ab00511516a3e49a05d8d094f364e0778783af2938f
LABEL maintainer="sgrep@r2c.dev"

COPY --from=build /home/opam/sgrep/_build/default/bin/main_sgrep.exe /bin/sgrep

COPY scanners/* /home/lib/salus/scanners/