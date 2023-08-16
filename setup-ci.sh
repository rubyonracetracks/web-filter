#!/bin/bash

# NOTE: set -o pipefail is needed to ensure that any error or failure causes the whole pipeline to fail.
# Without this specification, the CI status will provide a false sense of security by showing builds
# as succeeding in spite of errors or failures.
set -eo pipefail

echo ''
echo 'It is time to up SSH key files.'
echo 'This allows GitHub Workflows to use the git clone command to'
echo 'download an existing repository.'
echo ''
echo 'If you have already done this, then press Ctrl-Break to stop now.'
echo 'To continue, press Enter.'
read
echo ''

source bin/definitions

TYPE='ed25519'
FILENAME="id_$TYPE"
PATHNAME_SSH="$HOME/.ssh"
PATHNAME_SSH_OLD="$HOME/.ssh-old-$TIME_STAMP"
PATHNAME_SSH_NEW="$HOME/.ssh-$TIME_STAMP"
PATHNAME_PRIVATE="$PATHNAME_SSH/$FILENAME"
PATHNAME_PUBLIC="$PATHNAME_PRIVATE.pub"
PATHNAME_KNOWN_HOSTS="$PATHNAME_SSH/known_hosts"

echo "STEP 4: saving the old SSH key files in $PATHNAME_SSH_OLD (if applicable)"
if [ -d "$PATHNAME_SSH" ]; then
  mv $PATHNAME_SSH $PATHNAME_SSH_OLD
fi

# Use default path name for SSH key files.
# Use no password for the SSH key files.
# Piping in the newline character means automatically pressing enter.
echo 'STEP 5: generating the SSH key'
ssh-keygen -t "$TYPE" -N '' -f "$PATHNAME_PRIVATE" -C 'jhsu802701@jasonhsu.com' <<<$'\n'

wait
echo '------------'
echo 'ssh-agent -s'
eval "$(ssh-agent -s)"
echo ''
wait

echo 'STEP 6: adding the SSH private key to the ssh-agent'
ssh-add ~/.ssh/id_$TYPE
echo ''

# Necessary to establish the authenticity of the host and skip another prompt
echo 'STEP 7: ssh-keyscan'
ssh-keyscan -H github.com >> ~/.ssh/known_hosts

echo "STEP 8: Saving the new ssh keys in $PATHNAME_SSH_NEW"
cp -r $PATHNAME_SSH $PATHNAME_SSH_NEW

echo 'STEP 9: Go to https://github.com/settings/keys .'
echo "Copy the contents of $PATHNAME_PUBLIC to SSH Public Keys and"
echo 'click on "Save".'
echo 'Press Enter when finished.'
read
echo ''
echo 'STEP 10: Go to this repository on GitHub.'
echo 'Click on Settings -> Security -> Secrets and Variables -> Actions'
echo 'Add the repository secret SSH_PUBLIC_KEY (if it is not already present)'
echo 'or replace the value (if it is already present).'
echo "Copy and paste the contents of $PATHNAME_PUBLIC"
echo 'into the value of this repository secret.'
echo "Click on 'Add secret' or 'Update secret' button, whichever is applicable."
echo 'Press Enter when finished.'
read
echo ''
echo 'STEP 11: Repeat the above procedure, but paste the contents of'
echo "$PATHNAME_PRIVATE into the repository secret SSH_PRIVATE_KEY."
echo 'Press Enter when finished.'
read
echo ''
echo 'STEP 12: Repeat the above procedure, but paste the contents of'
echo "$PATHNAME_KNOWN_HOSTS into the repository secret SSH_KNOWN_HOSTS."
echo 'Press Enter when finished.'
read
echo ''
echo 'Congratulations!  GitHub Workflows should now be able to automatically'
echo 'push changes to a repository.'
echo ''
