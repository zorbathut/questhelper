#!/bin/bash

function die {
  echo $* 1>&2
  exit 1
}

export BOTKEY="`pwd`/botkey"
export GIT_SSH="`pwd`/botssh.sh"

cd ..

git status &> /dev/null && die "Working directory not clean; script may have crashed last run."

SSH_REMOTE="qhbot@idiotbox-03"
WEB_REMOTE="http://smariot.hopto.org/translate/"

function filter_names {
  # Keep only the '____.lua' portion of a name.
  sed -n "s/.*\\(....\\.lua\\)$/\\1/p"
}

function remote_list {
  # Get list of files on the server.
  ${GIT_SSH} ${SSH_REMOTE} "ls -1 /server/http/cgi/lang/lang_????.lua" | filter_names
}

function local_list {
  # Get list of local files.
  ls -1 lang/????.lua | filter_names
}

function changed {
  # Check if the file on the server matches the local file.
  if [ "`${GIT_SSH} ${SSH_REMOTE} \"cat /server/http/cgi/lang/lang_${1} | sha1sum -\"`" == "`cat lang/${1} | sha1sum -`" ] ; then
    echo "same"
  else
    echo "changed"
  fi
}

function uploadifchanged {
  # Uploads a local file to the server, if it has been changed.
  if [ `changed ${1}` == "changed" ] ; then
    echo "Uploading ${1}..."
    ${GIT_SSH} ${SSH_REMOTE} "cat > /server/http/cgi/lang/lang_${1}" < lang/${1} || die "Error uploading '${1}'."
    
    # Make sure webserver is able to write to this file.
    # Sorry whoever put all that work into editing csCZ; I'm sure seeing the 'unable to save' message was disheartening,
    # but fear not, it was emailed to me, and I applied it for you. :)
    ${GIT_SSH} ${SSH_REMOTE} "chmod g+w /server/http/cgi/lang/lang_${1}" || die "Error making file writable '${1}'."
  fi
}

echo "Updating repository..."

git checkout master &> /dev/null || die "Error switching to 'master' branch."
git pull smariot master --tags &> /dev/null || die "Error pulling changes from smariot's repository."
git pull zorba master --tags &> /dev/null || die "Error pulling changes from zorba's repository."

# Step zero, replace the enus.lua file on the server, all the other files will be formatted using it as a template
# when we download them.
if [ -e lang/enus.lua ] ; then
  echo "Making sure server has latest version of enus.lua..."
  uploadifchanged "enus.lua"
else
  die "'lang/enus.lua' has, like, been abducted by aliens!"
fi

# Step one, switch to our translations branch, it should match the state the files were in
# the last time this script was run. (We're not merging yet, we'll do that after we commit,
# so that git can fix any conflicts for us.
echo "Switching to translations branch..."
git checkout translations &> /dev/null || die "Error switching to translations branch."

# Step two, download all the translations from the server, and add them to the repository.
for FILE in `remote_list` ; do
  # enus shouldn't be translated; skip it.
  if [ ${FILE} != "enus.lua" ] ; then
    echo "Downloading ${FILE}..."
    wget -q ${WEB_REMOTE}${FILE} -O lang/${FILE} || die "Error updating 'lang/${FILE}'"
    git add lang/${FILE} || die "Error adding 'lang/${FILE}' to repository."
  fi
done

# Step three, update language files in QuestHelper.toc
echo "Updating translations files in QuestHelper.toc"
(
FIRST="true"
while read -r LINE ; do
  case ${LINE} in 
    # Does the line look like a translation?
    lang\\????.lua )
      # Is this the first translation we've seen?
      if [ ${FIRST} == "true" ] ; then
        FIRST="false"
        # Dump all the translations; replace slashes with backslashes.
        ls -1 lang/????.lua | sed "s/\\//\\\\/g"
      fi
    ;;
    # Otherwise, write the original line back out.
    *)
      echo "${LINE}"
    ;; 
  esac
done
# Did we actually find any translations?
if [ ${FIRST} == "true" ] ; then
  die "Didn't find any translations in QuestHelper.toc! What manner of sorcery is this?"
fi
) < QuestHelper.toc > _QuestHelper.toc

mv -f _QuestHelper.toc QuestHelper.toc || die "Error copying over updated QuestHelper.toc"
git add QuestHelper.toc || die "Error adding 'QuestHelper.toc' to repository."

# Step four, create the commit.
echo "Creating a new commit."
git commit -m "Automated update from: http://smariot.hopto.org/translate" &> /dev/null || die "Error creating commit. (Possibly because there was nothing to commit.)"

# Step five, merge with master.
git pull . master &> /dev/null || die "Error merging with 'master' into translations."

# Step six, delete any removed translations.
for FILE in `remote_list` ; do
  if [ ${FILE} != "enus.lua" ] ; then
    if [ ! -e "lang/${FILE}" ] ; then
      echo "Deleting ${FILE} from the server."
      ${GIT_SSH} ${SSH_REMOTE} "rm /server/http/cgi/lang/lang_${FILE}" || die "Error deleting '${FILE}' from server."
    fi
  fi
done

# Step seven, upload the translations to the server, in case they were changed by the merge.
echo "Uploading updated translations back to server..."
for FILE in `local_list` ; do
  uploadifchanged ${FILE}
done

# Step eight, switch back to master branch, merge, and upload.
echo "Merging translations back into master branch."
git checkout master &> /dev/null || die "Error switching to 'master' branch."
git pull . translations &> /dev/null || die "Error pulling changes from 'translations' branch."

# Step nine, push the changes back to the server.
echo "Pushing changes..."
git push qhbot master --tags &> /dev/null || die "Error pushing changes."

echo "All done!"
