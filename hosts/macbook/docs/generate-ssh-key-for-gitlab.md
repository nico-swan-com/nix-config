# Generate an SSH key pair

If you do not have an existing SSH key pair, generate a new one:
**Prerequisites**
* Ensure you have a .ssh directory in your home folder
```
mkdir ~/.ssh
```

1) Open a terminal.

2) Run ssh-keygen -t followed by the key type and an optional comment. This comment is included in the .pub file that’s created. You may want to use an email address for the comment.
For example, for ED25519:
```
ssh-keygen -t ed25519 -C "<email-address>"
```

3) Enter the following `/Users/<username>/.ssh/id_gitlab` Press `Enter`. Output similar to the following is displayed:
```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519):
```

Accept the suggested filename and directory, unless you are generating a deploy key or want to save in a specific directory where you store other keys.

You can also dedicate the SSH key pair to a specific host.

Do not specify a passphrase (Press `Enter` to add no passphrase) 

```
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```
A confirmation is displayed, including information about where your files are stored.

A public and private key are generated. Add the public SSH key to your GitLab account and keep the private key secure.

## Add an SSH key to your GitLab account
To use SSH with GitLab, copy your public key to your GitLab account:

1) Copy the contents of your public key file. You can do this manually or use a script. For example, to copy an ED25519 key to the clipboard:

macOS
```
tr -d '\n' < ~/.ssh/id_gitlab.pub | pbcopy
```

2) Sign in to GitLab.
3) On the left sidebar, select your avatar.
4) Select Edit profile.
5) On the left sidebar, select SSH Keys.
6) Select Add new key.
7) In the Key box, paste the contents of your public key. If you manually copied the key, make sure you copy the entire key, which starts with ssh-ed25519 and may end with a your email address.
8) In the Title box, type a description, like Work Laptop or Home Workstation.
9) Optional. Select the Usage type of the key. It can be used either for Authentication or Signing or both. Authentication & Signing is the default value.
10) Optional. Update Expiration date to modify the default expiration date.
    * Administrators can view expiration dates and use them for guidance when deleting keys.
    * GitLab checks all SSH keys at 01:00 AM UTC every day. It emails an expiration notice for all SSH keys that are scheduled to expire seven days from now.
    * GitLab checks all SSH keys at 02:00 AM UTC every day. It emails an expiration notice for all SSH keys that expire on the current date.
11) Select Add key.


# Apply ssh config
Allow gitlab to connect with SSH 

Create a `~/.ssh/config` file with the following content:

```
Host gitlab.com 
    HostName gitlab.com
    IdentitiesOnly yes
    IdentityFile ~/.ssh/id_gitlab
Host *
    ForwardAgent no
    Compression no
    ServerAliveInterval 0
    ServerAliveCountMax 3
    UserKnownHostsFile ~/.ssh/known_hosts
    ControlMaster no
    ControlPath ~/.ssh/master-%r@%n:%p
    ControlPersist no
    UseKeychain yes
    AddKeysToAgent yes

```
