#!/bin/bash
WORKINGDIR=`pwd`
BUILDDIR=~/build
rm -f ./EDCOP.iso
#cd $BUILDDIR/isolinux
rm -rf $BUILDDIR/isolinux/repodata
cd $BUILDDIR/isolinux
createrepo -g ../comps.xml .
mkisofs -o EDCOP.iso -J -joliet-long -rational-rock -untranslated-filenames -translation-table -input-charset utf-8 -x ./lost+found -V "EDCOP" -volset "EDCOP" -A "EDCOP" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot $BUILDDIR/isolinux/
implantisomd5 EDCOP.iso
isohybrid -u EDCOP.iso
mv EDCOP.iso $WORKINGDIR
