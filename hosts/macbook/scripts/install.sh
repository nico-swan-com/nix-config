#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Function to print messages in color
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Function to install Darwin
install_darwin() {
    print_message "$BLUE" "Installing darwin..."
    print_message "$YELLOW" "When asked please answer as follows when prompted...."
    print_message "$YELLOW" "Would you like to edit the default configuration.nix before starting? [y/N] N"
    print_message "$YELLOW" "Would you like to manage <darwin> with nix-channel? [y/N] y"
    echo ""
    echo ""
    nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
    ./result/bin/darwin-installer <<EOF
N
y
EOF
}

# Function to install Home Manager
install_home_manager() {
    print_message "$BLUE" "Installing home-manager"
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
}

install_homebrew() {
    read -p "Would you like to install Homebrew (Y/n): " install_homebrew
    install_homebrew=${install_homebrew:-"Y"}
    if [ "$install_homebrew" == "Y" ]; then
        print_message "$BLUE" "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Function to check secrets repository
check_secrets_repository() {
    read -p "Have you created a secrets repository (Y/n): " have_created_nix_secrets_repository
    have_created_nix_secrets_repository=${have_created_nix_secrets_repository:-Y}
    if [ ! -f ~/.config/sops/age/keys.txt ] || [ "$have_created_nix_secrets_repository" != "Y" ]; then
        print_message "$RED" "Please create a secrets repository before running this script"
        print_message "$RED" "See the nix-secrets for more information"
        exit 1
    fi
}

# Function to get user input
get_user_input() {
    read -p "Enter the secrets GitLab repository URL (default: git@gitlab.com:nico.swan.bcb/nix-secrets.git): " NIX_SECRETS_URL
    NIX_SECRETS_URL=${NIX_SECRETS_URL:-"git@gitlab.com:nico.swan.bcb\\/nix-secrets.git"}
    NIX_SECRETS="$(echo "$NIX_SECRETS_URL" | sed 's/gitlab.com:/gitlab.com\\\//')"
    echo ""

    read -p "Enter username (default: $USER): " username
    username=${username:-$USER}

    read -p "Enter full name (default: Full Name): " fullname
    fullname=${fullname:-"Full Name"}

    read -p "Enter email (default: $USER@bcbgroup.io): " email
    email=${email:-"user@bcbgroup.io"}

    read -p "Enter locale (default: en_ZA.UTF-8): " locale
    locale=${locale:-"en_ZA.UTF-8"}

    read -p "Enter timezone (default: Africa\/Johannesburg): " timezone
    timezone=${timezone:-"Africa\/Johannesburg"}

    sed -i.bak -e "s/username = \".*\";/username = \"$username\";/g" \
    -e "s/fullname = \".*\";/fullname = \"$fullname\";/g" \
    -e "s/email = \".*\";/email = \"$email\";/g" \
    -e "s/locale = \".*\";/locale = \"$locale\";/g" \
    -e "s/timezone = \".*\";/timezone = \"$timezone\";/g" \
    -e "s/url = .*nix-secrets-boilerplate.*\";$/url = \"git\+ssh:\/\/$NIX_SECRETS\?ref=main\&shallow=1\";/g" flake.nix
    echo ""
    print_message "$GREEN" "flake.nix has been updated with the new values."
    print_message "$YELLOW" "Please validate the flake updates and save."
    sleep 3
    vi flake.nix
    read -p "Is the flake.nix file correct (Y/n): " updated_correctly
    if [ "$updated_correctly" != "Y" ]; then
        print_message "$RED" "Aborting installation, please execute darwin-rebuild when flake is updated correctly."
        exit 1
    fi
}

update_custom_config() {
    read -p "Would you like to update the inital configuration.nix (y/N): " update_configuration
    update_configuration=${update_configuration:-"N"}
    if [ "$update_configuration" == "y" ]; then
       vi configuration.nix
    fi

    read -p "Would you like to update the inital home.nix (y/N): " update_home
    update_home=${update_home:-"N"}
    if [ "$update_home" == "y" ]; then
       vi home.nix
    fi
}

rebuild_configuration() {
    source /etc/static/bashrc
    export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
    print_message "$BLUE" "Updating configuration and installing packages"
    # Rebuild system
    NIX_SECERTS_INPUT="git+ssh://$(echo "$NIX_SECRETS_URL" | sed 's/gitlab.com:/gitlab.com\//')?ref=main&shallow=1"
    if ! darwin-rebuild switch --flake .#main; then
        print_message "$RED" "Failed to rebuild configuration. Please check the logs for details."
        print_message "$RED" "Please execute darwin-rebuild when flake is updated correctly."
        print_message "$RED" "darwin-rebuild switch --flake .#main"
        return 1
    fi

    echo ""
    echo ""
    echo ""
    print_message "$GREEN" "Setup completed :)"
    print_message "$YELLOW" "You can now edit your configuration.nix or home.nix file and run 'just rebuild' to apply changes."
    print_message "$YELLOW" "OR The command to rebuild is 'darwin-rebuild switch --flake .#main' to apply changes."
    echo ""
    print_message "$RED" " Close this terminal for shell changes to take affect."
}

# Main script execution
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
install_darwin
source /etc/static/bashrc

install_home_manager
install_homebrew
check_secrets_repository
get_user_input
update_custom_config
rebuild_configuration
