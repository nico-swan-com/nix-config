# Developer environment setup

This project uses the Nix package manager to manage your local environment to create reproducible setup quickly and consistency for all developers. 

See [the bcb-nixpkgs project](https://gitlab.com/bcb-projects/bcb-internal-dev-tooling/bcb-nixpkgs/-/blob/main/README.md?ref_type=heads) for a list of packages available for use. This project provides additional services and packages 
See the [home.nix](./home.nix) and [configuration.nix](./configuration.nix) file for a list of these additions to the packages and configuration.
Some key features
* Adds secrets management such as your gitlab token and setup your .npmrc file
* Setup VScore with some common extensions
* Install and configure alacritty, kitty, iTerm2(with homebrew installation)
* Install and configure tmux and have alacritty start with a tmux session
* Install LunarVim as a TUI IDE
* Install the FiraCode Nerd font
* Install Nodejs 20 as default 
* Added bcb modules that are not enabled by default  (see comments)
  * services.bcb.database.postgres (A clean postgres installation) 
  * programs.bcb.utils.kubernetes - Adds extra utilities for kubernetes see [the bcb-nixpkgs project](https://gitlab.com/bcb-projects/bcb-internal-dev-tooling/bcb-nixpkgs/-/blob/main/README.md?ref_type=heads) 
  * Collection of services that will automatically create port forwarding to sandbox for all services 
     * services.bcb.host-updater -- Updates the hosts file with sandbox ip addresses
     * services.nginx - Setup nginx 
     * services.bcb.port-forward - collect and create configuration for mprocs to open port forwards for the sandbox services
     * services.bcb.process-manager - creates a custom mprocs configuration and start-* command to manage processes
* Optionally Install Rectangle and NVM via homebrew if it is installed

## Setup

[Here is a video that setups you thought the below process](https://bcbgroup-io.slack.com/files/U026X6MRGE8/F07NBSJNULB/rebuild-local-development-environment-with-nix.mp4)

**Prerequisites**
GitLab SSH key setup, follow the steps in [GitLab SSH key setup](./docs/generate-ssh-key-for-gitlab.md) to create and add your GitLab SSH key.


### Install the Nix package manager

Run the following command to install Nix:
```
sh <(curl -L https://nixos.org/nix/install)
```
This will install the Nix package manager for you. Please follow the instruction.

* [NixOS](https://nixos.org/download/#download-nix)

Once the install is complete you can run `nix-shell -p git` to install git for the next steps.


### Configure your secrets
*Important*: Creating a secrets project is the first step. You need to create a secrets project on GitLab. The secrets project is used to store all the secrets, keys, tokens, etc we don't want to store these as unencrypted stings in GitLab.

**Ensure that you have installed to Nix page manager.**

This section will describe how to use SOPS to encrypt the secrets and link it to this configuration.



1) Create a new `Personal project` on GitLab called `nix-secrets`. 
2) Clone or download and copy the example secrets project to your local machine to the `~/.config/nix-secrets` directory. 
```
nix-shell -p git
git clone git@gitlab.com:bcb-projects/bcb-internal-dev-tooling/nix-secrets-boilerplate.git ~/.config/nix-secrets
```
3) Change the remote origin of the cloned secrets project to your Personal project on GitLab and push this initial commit. 
```
cd ~/.config/nix-secrets    

git remote set-url origin git@gitlab.com:<username>/nix-secrets.git

git add.
git commit -m "Initial commit"
git push --set-upstream origin main
```
3) Follow the [README](https://gitlab.com/bcb-projects/bcb-internal-dev-tooling/nix-secrets-boilerplate/-/blob/main/README.md?ref_type=heads) in the secrets project to setup the secrets.


### Configure your configuration

## Initial setup

1) Create a new `Personal project` on GitLab called `nix-config`. 

2) Clone the developer nix config project to your local machine and change the remote origin of the cloned project to your Personal project on GitLab.
```
git clone git@gitlab.com:bcb-projects/bcb-internal-dev-tooling/developer-nix-config.git ~/.config/nix-config

cd ~/.config/nix-config
```
3) Set the git to link to you Personal project on GitLab and push this initial
```
git remote set-url origin git@gitlab.com:<username>/nix-config

git add .
git commit -m "Initial commit"
git push --set-upstream origin main
```
3) Run `nix-shell` to start the ephemeral shell. This will install all that you will need for the next steps in this guide.

### Automated Install
When you have initiated `nix-shell` you would be able to run the `just install` and follow the instructions.
This will execute the below Manual steps 

### Manual Install 
#### Setup nix-darwin
This is needed for NixOS to work on MacOS
For more information on how to install nix-darwin, see [here](https://github.com/LnL7/nix-darwin)

1) Install Nix Darwin
```
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
source /etc/static/bashrc
```
2) The installation would ask the following questions, please answer as follows:  
```
Installing nix-darwin...

copying example configuration.nix
Would you like to edit the default configuration.nix before starting? [y/N] N
Would you like to manage <darwin> with nix-channel? [y/N] y

```

#### Setup nixos Home-manager standalone
1) Configure channel for home-manager
```
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```
2) Run installer
```
nix-shell '<home-manager>' -A install
```
3) Setup env incurrent terminal session
```
sudo $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
```

#### Update the `flake.nix` file with your details 

1) Update the `nix-secrets` locations
```
    # Secrets
    # Replace the link with your secrets repository
    nix-secrets = {
      url = "git+ssh://git@gitlab.com/nico.swan.bcb/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

```

2) Search for `darwinConfigurations.main` and update your username, full name and email address

```
      darwinConfigurations.main = mkSystem "main" {
        system = "aarch64-darwin";
        username = "nicoswan";
        fullName = "Nico Swan";
        email = "nico@bcbroup.io";
        darwin = true;
      };

```

### (Optionally) Homebrew Installations
In order to install with homebrew you need to install the package manager.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
See [homebrew-packages](nix-darwin/homebrew-packages.nix)

### Rebuild your nix configuration 

If you have updated the flake.nix file with you secrets
```
darwin-rebuild switch --flake .#main
```
- OR -
If you haven't updated the flake.nix file with your secrets you can overwrite them

```
darwin-rebuild switch --flake .#main --override-input nix-secrets "git+ssh://git@gitlab.com/nico.swan.bcb/nix-secrets.git?ref=main&shallow=1" 
```

This should conclude the installation process 
**~ FIN ~**



# Useful just command
* just - list all the just commands

* install - Execute the initial installation steps for this nix-configuration 
* rebuild - Rebuild the nix configuration

* Nix management:
    * just update - update the flake.lock and update all packages
    * nixgc - Garbage collect the nix store
    * nixos-clean - garbage collect and clean the nix store

* Secrets management:
    * just sops - Open and edit your sops secrets.yaml file in ../nix-secrets
    * just age-key - Generate a new age key and add it to the .sops.yaml file
    * just rekey - Rekey all secrets in key file
    * just update-nix-secrets - update the ../nix-secrets project 
  





