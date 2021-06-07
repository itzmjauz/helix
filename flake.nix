{
  description = "A post-modern text editor.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nmattia/naersk";
  };

  outputs = inputs@{ self, nixpkgs, naersk, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ rust-overlay.overlay ]; };
        rust = (pkgs.rustChannelOf {
          date = "2021-05-01";
          channel = "nightly";
        }).minimal; # cargo, rustc and rust-std
        naerskLib = naersk.lib."${system}".override {
          # naersk can't build with stable?!
          # inherit (pkgs.rust-bin.stable.latest) rustc cargo;
          rustc = rust;
          cargo = rust;
        };
      in rec {
        packages.helix = naerskLib.buildPackage {
          pname = "helix";
          root = ./.;
          src = pkgs.fetchFromGitHub {
            owner = "helix-editor";
            repo = "helix";
            fetchSubmodules = true;
            rev = "9821beb5c4b36f7c34ae6a5cb014b3eb68b9233a"; 
            # ^ ideally tag a version here e.g. v0.0.10
            # the required commit d5de91... isn't part of a release yet
            sha256 = "sha256-TvCZcEYm9xRNaDuQM4DT9zJg70rCT77U5LsEnhwxvA4=";
          };
        };
        defaultPackage = packages.helix;
        devShell = pkgs.callPackage ./shell.nix {};
      });
}
