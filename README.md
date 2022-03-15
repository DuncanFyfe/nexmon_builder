# nexmon\_builder
Build and deploy scripts for nexmon and nexmon\_csi

## Repository Structure

The repository uses an empty *external* and *secrets* directory as a spaces for external and secret resources which should not be committed.  For example, an evaluated version of *rpi-source* is linked to here for copying to Raspberry Pi boxes rather than assuming the external github repository is safe.  Similarly the github fingerprint is placed here too.

The file *external_resources.yml* stores variables which refer to the contents of the *external* or *secrets* directories.  Edit these to suit your local needs.

## Playbooks

### raspios\_base.yml

Installs common packages needed for a functional/sane Raspberry Pi.  Along with git the Github SSH fingerprint is installed.  SSH keys and an appropriate ssh_config block are also installed for Github access over SSH.

Assumes:

*  Any target node *pi* user account is already SSH accessible for ansible.
*  Package upgrades are performed elsewhere.

Variables needed:

*  *PI\_GITHUB\_ID\_FILE*: Points to a file containing the SSH private key for Github access.
*  *PI\_GITHUB\_ID\_PUB\_FILE* : Points to a file containing the SSH public key for Github access.
*  *GITHUB\_SSH\_FINGERPRINT\_FILE*: Points to a file containing theGithub SSH fingerprint.
*  *SSH\_CONFIG\_FILE*: Points to a file containing the configuration block to be added to the pi user's ssh_config file.

### nexmon\_builder.yml

Installs dependencies needed to build *nexmon* and *nexmon\_csi*.  The *nexmon_builder* repository (this one!) is cloned to the targets too for the *nexmon_install.sh* script.
At this point in time nexmon\_builder.yml does not run the *nexmon_install.sh* script.  That remains a task for the user (build script failures are not handled well enough to make this part of the playbook).

Assumes:

*  The targets have had the raspios\_base.yml playbook applied.


Variables needed:

*  *RPI\_SOURCE*: Points to a local copy of *rpi-source* to be installed.


### External Resources

* [rpi-source](https://raw.githubusercontent.com/RPi-Distro/rpi-source/master/rpi-source)
* [nexmon](https://github.com/seemoo-lab/nexmon)
* [nexmon_csi (1)](https://github.com/seemoo-lab/nexmon_csi)
* [nexmon_csi (2)](https://github.com/nexmonster/nexmon_csi) 
* [nexmon_builder](https://github.com/DuncanFyfe/nexmon_builder) 






