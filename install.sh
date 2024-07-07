#!/bin/sh
# Automated script to install nix on a new machine

NIX_CONFIG_PROJECT_URL=https://gitlab.com/nico.swan.bcb/nix-config
NIX_CONFIG_INSTALL_DIR=~/.config/nix-config-intall-test

if [ ! -f ~/.config/sops/age/keys.txt ] ; then
    echo "Please ensure you have configured your sops decryption keys file"
    echo "See $NIX_CONFIG_PROJECT_URL/-/blob/main/README.md for more information"
    exit 1
fi
export SOPS_AGE_KEY_FILE="~/.config/sops/age/keys.txt"

read -p "Have you created a secrets repository (Y/n): " have_created_nix_secrets_repository
if [ "$have_created_nix_secrets_repository" != "Y" ]; then
    echo "Please create a secrets repository before running this script"
    echo "See $NIX_CONFIG_PROJECT_URL/-/blob/main/README.md for more information"
    exit 1
fi


echo "Retrieving nix configuration"
GIT_CMD_CLONE_NIX_CONFIG="git clone git@gitlab.com:nico.swan.bcb/nix-config.git $NIX_CONFIG_INSTALL_DIR"
nix-shell -p git --command "$GIT_CMD_CLONE_NIX_CONFIG"
cd $NIX_CONFIG_INSTALL_DIR

# Remove the git origin after coloning 
#nix-shell -p git --command "git remote remove origin"

echo "Enter the secrets GitLab repository URL i.e. git@gitlab.com:nico.swan.bcb/nix-secrets.git";
read -p ": " NIX_SECRETS_URL

# Open up editor to manually edit secrets.yaml before install
# if [ -z "$EDITOR" ]; then
#     EDITOR=vi;
# fi
#GIT_CMD_CLONE_NIX_SECRETS="git clone $NIX_SECRETS_URL ~/.config/nix-secrets"
#nix-shell -p git --command "$GIT_CMD_CLONE_NIX_SECRETS"
# cd ~/.config/nix-secrets
# nix-shell . --command "sops secrets.yaml"


# Rebuild system
NIX_SECERTS_INPUT="git+ssh://$(echo "$NIX_SECRETS_URL" | sed 's/gitlab.com:/gitlab.com\//')?ref=main&shallow=1"
darwin-rebuild switch --flake $NIX_CONFIG_INSTALL_DIR#macbook-pro-m1 --override-input nix-secrets $NIX_SECERTS_INPUT 