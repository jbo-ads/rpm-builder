# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  config.vm.hostname = "vagrant-rpm"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provision "shell", run: "always", inline: <<-SHELL

    #########################################
    #  Préparation générale
    #

    ###  Outils et dépendances de base
    yum install -y epel-release
    yum install -y unzip gcc-c++ patchelf \
                   java-11 java-11-devel

    ###  Dossier d'installation
    export INSTALL_DIR=/opt/geo

    ###  Placement dans le dossier partagé
    cd /vagrant

    #########################################
    #  Kakadu
    #

    ###  Préparation du dossier d'installation
    rm -rf ${INSTALL_DIR}
    mkdir -p ${INSTALL_DIR}/{lib,share/kdu}

    ###  Récupération des sources
    kduzip="v7_A_2-01185C.zip"
    if [ ! -f ${kduzip} ]
    then
      printf "\nErreur:\n" >&2
      printf "La version 7.10.2 de la librairie Kakadu (${kduzip})" >&2
      printf " est nécessaire.\nMerci de la récupérer avant de" >&2
      printf " relancer la procédure.\n \n" >&2
      exit 1
    fi
    test -d ${kduzip%.zip} || unzip -qq ${kduzip}
    cd ${kduzip%.zip}

    ###  Préparation de la compilation
    sed -i 's/^\(INCLUDE_AVX2\)/# \1/' $(find . -name Makefile-Linux-x86-64-gcc)
    sed -i 's/\(-m64\)/\1 -fPIC/' apps/make/Makefile-Linux-x86-64-gcc

    ###  Compilation
    cd make
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
    make -f Makefile-Linux-x86-64-gcc
    cd ..

    ###  Installation des librairies et réglage du RPATH
    cp lib/Linux-x86-64-gcc/libkdu* ${INSTALL_DIR}/lib
    cd ${INSTALL_DIR}/lib
    mv libkdu_a7AR.so libkdu.so
    ln -s libkdu.so libkdu_a7AR.so
    for so in libkdu_jni.so libkdu.so libkdu_v7AR.so ; do
      patchelf --set-rpath '$ORIGIN' ${so}
    done
    cd -

    ###  Installation des sources et objets dont GDAL aura besoin
    mkdir -p ${INSTALL_DIR}/share/kdu/coresys/common
    cp ./coresys/common/*.h ${INSTALL_DIR}/share/kdu/coresys/common
    for dir in compressed_io jp2 image args support kdu_compress ; do
      mkdir -p ${INSTALL_DIR}/share/kdu/apps/$dir
      cp ./apps/$dir/*.h ${INSTALL_DIR}/share/kdu/apps/$dir
    done
    mkdir -p ${INSTALL_DIR}/share/kdu/apps/make
    cp ./apps/make/*.o ${INSTALL_DIR}/share/kdu/apps/make
    mkdir -p ${INSTALL_DIR}/share/kdu/apps/caching_sources
    cp ./apps/caching_sources/* ${INSTALL_DIR}/share/kdu/apps/caching_sources

    ###  Fin
    cd ..
    find /opt/geo -type f -or -type l


  SHELL

end
