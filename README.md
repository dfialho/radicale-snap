# Radicale snap

*Unofficial* Snap package for [radicale](http://radicale.org).

Radicale is a free and open-source CalDAV and CardDAV server. It is a complete calendar and contact storing and manipulating solution. It can store multiple calendars and multiple address books. Calendar and contact manipulation is available from both local and distant accesses, possibly limited through authentication policies. It aims to be a lightweight solution, easy to use, easy to install, easy to configure. As a consequence, it requires few software dependencies and is pre-configured to work out-of-the-box.

[![Snap Status](https://build.snapcraft.io/badge/dfialho/radicale-snap.svg)](https://build.snapcraft.io/user/dfialho/radicale-snap)

## Install


## Building this snap

Using Ubuntu 16.04 or newer type the following commands:

1. Install snapcraft (if not installed already): 
		
		sudo snap install snapcraft --classic	

1. Install and initialize LXD. This step is required to perform a 'cleanbuild'
	
		sudo snap install LXD
		sudo lxd init 	# accepting the defaults is fine

1. Clone the repository and build the snap

		git clone git@github.com:dfialho/radicale-snap.git
		cd radicale-snap
		snapcraft cleanbuild

The snap will be built in a clean LXD container and placed in the current working directory. The built snap can be installed using: 

	sudo snap install radicale-dfialho_*.snap --dangerous
