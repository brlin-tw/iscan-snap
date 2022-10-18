# Unofficial Snap Packaging for Image Scan! for Linux (V2, UNOFFICIAL)

This is the unofficial snap packaging for [Image Scan! for Linux, version 2](http://support.epson.net/linux/src/scanner/iscan/), [Snaps are universal Linux packages](https://snapcraft.io).

Refer [snap/README.md](snap/README.md) for user-oriented information.

<!--
![GitHub Actions workflow status badge](https://github.com/_namespace_/_project_/actions/workflows/check-potential-problems.yml/badge.svg "GitHub Actions workflow status") [![pre-commit enabled badge](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white "This project uses pre-commit to check potential problems")](https://pre-commit.com/) [![REUSE Specification compliance badge](https://api.reuse.software/badge/github.com/_namespace_/_project_ "This project complies to the REUSE specification to decrease software licensing costs")](https://api.reuse.software/info/github.com/_namespace_/_project_)
-->

## Remaining Tasks

Snapcrafters ([join us](https://forum.snapcraft.io/t/join-snapcrafters/1325)) are working to land snap install documentation and the [snapcraft.yaml](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/blob/master/snap/snapcraft.yaml) upstream so [Project] can authoritatively publish future releases.

* [x] Create _snap_name_-snap (or any valid name you prefer) repository via the [Use this template](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/generate) button above

      It is recommended to *avoid forking the template repository* unless you're working on the template itself because you can only fork a repository once
* [x] Update the description of the repository
* [x] Update logos and references to `[Project]`, `my-awesome-app`, `_namespace_`, `_project_`, and other placeholder names in `README.md`, `snap/README.md`, and `snap/snapcraft.yaml`
* [x] Add upstream contact information to this `README.md`
* [x] Create a snap that runs in `devmode`, [or in `classic` confinement if that's not possible](https://forum.snapcraft.io/t/subtle-differences-between-devmode-and-classic-confinement-snaps/7267)
    + [ ] If the snap must be packaged under `classic` confinement, file a [classic confinement request](https://forum.snapcraft.io/t/process-for-reviewing-classic-confinement-snaps/1460) topic in the Snapcraft Forum, under the `store` topic category - [template](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/wiki/Classic-Confinement-Request-Template) - [link]()
* [x] Add a screenshot to `snap/README.md`
* [x] Register the snap in the Snap Store, **using the preferred upstream name**(i.e. without custom postfix).  If the preferred upstream name is not available or reserved, [file a request to take over the preferred upstream name](https://dashboard.snapcraft.io/register-snap) and temporary use a name with personal postfix instead.
* [x] Setup [build.snapcraft.io](https://build.snapcraft.io) and publish the `devmode` snap in the Snap Store edge channel
* [ ] Add the provided Snapcraft build badge to `snap/README.md`
* [ ] Update snap's metadata, icons and screenshots on the [dashboard](https://dashboard.snapcraft.io)
* [ ] Add install instructions to `snap/README.md`
* [ ] File an Intent-To-Package issue/bug to the upstream's contact or issue/bug tracker to consolidate and let the upstream acknowledge the effort - [template](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/wiki/Intent-To-Package-Template) - [link]()
* [x] Convert the snap to `strict` confinement, or `classic` confinement if it qualifies
* [ ] Publish the confined snap in the Snap Store beta channel
* [ ] Update the install instructions in `snap/README.md`
* [ ] Post a call for testing on the [Snapcraft Forum](https://forum.snapcraft.io) - [template](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/wiki/Call-for-Testing-Template) - [link]()
* [x] Publish the snap in the Snap Store stable channel
* [ ] Update the install instructions in `snap/README.md`
* [ ] Post an announcement in the [Snapcraft Forum](https://forum.snapcraft.io) - [template](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/wiki/Release-Announcement-Template) - [link]()
* [ ] Submit a pull request or patch upstream that adds the `snapcraft.yaml` and any required assets/launchers - [example](https://github.com/htacg/tidy-html5/pull/749) - [link]()
* [ ] Submit a pull request or patch upstream that adds snap install documentation - [example](https://github.com/htacg/html-tidy.org/pull/11) - [link]()

If the upstream accepts the PRs **AND** willing to maintain the package on the Snap Store:
* [ ] Request upstream create a Snap Store developer account
* [ ] Create a topic [under the `store` category in the Snapcrafters Forum](https://forum.snapcraft.io/c/store) to request the snap be transferred to upstream - [template](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/wiki/Ownership-Transfer-Template#transfer-to-upstream) - [link]()

If the upstream rejects the offer:

* [ ] Ask a [Snapcrafters admin](https://github.com/orgs/snapcrafters/people?query=%20role%3Aowner) to fork your/upstream's repo into github.com/snapcrafters, transfer the snap name from you to snapcrafters, and configure the repo for automatic publishing into edge on commit - [template](https://github.com/Lin-Buo-Ren/snapcrafters-template-plus/wiki/Ownership-Transfer-Template#transfer-to-the-snapcrafters-organization) - [link]()

Finally:

* [ ] Ask the Snap Advocacy team to celebrate the snap - [explanation](https://forum.snapcraft.io/t/what-is-ask-the-snap-advocacy-team-to-celebrate-the-snap/8808/7) -  [link]()

If you have any questions, [post in the Snapcraft forum](https://forum.snapcraft.io).

<!--
Refer the following page for setting a Gravatar:

    Gravatar - Globally Recognized Avatars
    https://en.gravatar.com/

Refer the following page for how to generate Gravatar image URL:

    Developer Resources - Gravatar - Globally Recognized Avatars
    https://en.gravatar.com/site/implement/

You may generate the unique hash by using the following command in terminal:

    printf username@example.com | tr '[:upper:]' '[:lower:]' | md5sum

-->

## Contacts

| Packager | Upstream |
| :-: | :-: |
| [![Packager's avatar](http://gravatar.com/avatar/66a5b84972e73e895d5d68d48b1e1e21/?s=128)<br>林博仁<br>Buo-ren, Lin](mailto:Buo.Ren.Lin@gmail.com) | [EPSON](https://www.epsondevelopers.com/contact-us-scanner/) |

## Licensing

The licensing condition is different between the source recipe and the
built snap, refer the folling sections for details.

### Source recipe

This project comply with the REUSE specification, please refer the [.reuse/dep5](.reuse/dep5) file and each applicable file's header for licensing requirement of each resource.

### Built snap

The built snap, however, is licensing-wise problematic as it constitutes
the following materials:

* Most of the Image Scan! for Linux V2 application(GPLv2+)
* The non-free, conditionally redistributable esmod library(EPSON END
  USER SOFTWARE LICENSE with special exception that allows distributing
  linked combination of Image Scan! for Linux and esmod)
* The non-free, non-redistributable optional driver support plugins,
  firmware data, and other resources(EPSON END USER SOFTWARE LICENSE)

The esmod library, although shipped with a copy of the EPSON END USER
SOFTWARE LICENSE(/non-free/COPYING.EPSON.en.txt) claiming:

```plaintext
3.     Other Rights and Limitations.  You agree not to modify, adapt or
translate the Software and further agree not to attempt to reverse
engineer, decompile, disassemble or otherwise attempt to discover the
source code of the Software.  **You may not rent, lease, distribute,
lend the Software to third parties or incorporate the Software into a
revenue generating product or service.**  You may, however, transfer
all of your rights to use the Software to another person or legal
entity, provided that the recipient also agrees to the terms of this
Agreement and you transfer the Software, including all copies, updates
and prior versions, and the Epson Hardware, to such person or entity.
The Software is licensed as a single unit, and its component programs
may not be separated for some other use.  Further, you agree not to
place the Software onto or into a shared environment accessible via a
public network such as the Internet or otherwise accessible by others
outside the single location referred to in Section 1 above.
```

The frontend wrapper code from the same source archive
(/frontend/esmod-wrapper.hh) have another passage that specifically
gives permission to distribute the library, as long as it is a linked
combination including the two(Image Scan! for Linux V2 and the esmod
library):

```c
//  This file is part of the 'iscan' program.

...stripped...

//  **As a special exception, the copyright holders give permission
//  to link the code of this program with the esmod library and
//  distribute linked combinations including the two.**  You must obey
//  the GNU General Public License in all respects for all of the
//  code used other then esmod.
```

As for the device support non-free plugins and other resources, this
snap incorporated efforts to allow the user to obtain and use them
after acknowledge the EPSON END USER SOFTWARE LICENSE, without actually
shipping them in the snap package.

## References

* [Index of /linux/src/scanner/iscan](http://support.epson.net/linux/src/scanner/iscan/)  
  Upstream download archives
* [AUR (en) - iscan](https://aur.archlinux.org/packages/iscan)  
  Additional patches for newer OSes and non-free plugin information
* [hean01/iscan: Fixes for iscan and epkowa sane backend](https://github.com/hean01/iscan)  
  Additional patches for some problems.
* [ltrace for RHEL 6 and 7 | Red Hat Developer](https://developers.redhat.com/blog/2014/07/10/ltrace-for-rhel-6-and-7)  
  For ltrace(1) usage
* ltrace(1) manpage  
  For debugging possible hardcoded paths.
* [Zenity Manual](https://help.gnome.org/users/zenity/stable/index.html.en)  
  For usage of the Zenity dialogs
* [The Pango Markup Language](https://web.archive.org/web/20201028224156/https://developer.gnome.org/pygtk/stable/pango-markup-language.html)  
  For text formatting in Zenity info dialogs
* [Short Tip: Extract pre/post-install scripts from a rpm – /home/liquidat](https://liquidat.wordpress.com/2008/08/26/short-tip-extract-prepost-install-scripts-from-a-rpm/)  
  For info on how to extract maintenance scripts from a RPM package
