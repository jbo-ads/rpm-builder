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
    yum install -y unzip gcc-c++ patchelf cmake3 rpm-build \
                   git automake libtool \
                   java-11 java-11-devel

    ###  Dossier d'installation
    export INSTALL_DIR=/opt/geo

    ###  Placement dans le dossier partagé
    cd /vagrant


    #########################################
    #  Kakadu
    #

    if [ ! -f geo-kdu-*.x86_64.rpm ] ; then

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

      ###  Installation des librairies et réglage du RPATH
      cp lib/Linux-x86-64-gcc/libkdu* ${INSTALL_DIR}/lib
      cd ${INSTALL_DIR}/lib
      mv libkdu_a7AR.so libkdu.so
      ln -s libkdu.so libkdu_a7AR.so
      for so in libkdu_jni.so libkdu.so libkdu_v7AR.so ; do
        patchelf --set-rpath '$ORIGIN' ${so}
      done

      ###  Création du RPM
      cd /vagrant
      FICVER=${INSTALL_DIR}/share/kdu/coresys/common/kdu_compressed.h
      MAJOR=$(awk '/KDU_MAJOR_VERSION/{print $NF}' ${FICVER})
      MINOR=$(awk '/KDU_MINOR_VERSION/{print $NF}' ${FICVER})
      PATCH=$(awk '/KDU_PATCH_VERSION/{print $NF}' ${FICVER})
      rm -rf build
      mkdir build
      cd build
      cmake3 -DNAME=geo-kdu \
             -DVERSION="${MAJOR}.${MINOR}.${PATCH}" \
             -DRELEASE=1 \
             -DINSTALL_DIR=${INSTALL_DIR} \
             -DDIRS="lib;share" \
             ..
      cpack3 -G RPM
      mv *.rpm ..
      cd ..

    fi


    #########################################
    #  PROJ
    #

    if [ ! -f geo-proj-*.x86_64.rpm ] ; then

      ###  Préparation du dossier d'installation
      rm -rf ${INSTALL_DIR}
      mkdir -p ${INSTALL_DIR}

      ###  Récupération des sources
      test -d PROJ || git clone https://github.com/OSGeo/PROJ.git
      cd PROJ
      git checkout 5.2.0

      ###  Compilation et installation
      test -f configure || ./autogen.sh
      test -f Makefile || ./configure --prefix=/opt/geo
      make
      make install

      ###  Réglage du RPATH
      cd /opt/geo/lib
      patchelf --set-rpath '$ORIGIN' libproj.so.13.1.1
      for exe in ../bin/* ; do
        patchelf --set-rpath '$ORIGIN/../lib' ${exe}
      done

      ###  Création du RPM
      cd /vagrant
      FICVER=${INSTALL_DIR}/include/proj.h
      MAJOR=$(awk '/PROJ_VERSION_MAJOR/{print $NF}' ${FICVER})
      MINOR=$(awk '/PROJ_VERSION_MINOR/{print $NF}' ${FICVER})
      PATCH=$(awk '/PROJ_VERSION_PATCH/{print $NF}' ${FICVER})
      rm -rf build
      mkdir build
      cd build
      cmake3 -DNAME=geo-proj \
             -DVERSION="${MAJOR}.${MINOR}.${PATCH}" \
             -DRELEASE=1 \
             -DINSTALL_DIR=${INSTALL_DIR} \
             -DDIRS="lib;bin;include;share" \
             ..
      cpack3 -G RPM
      mv *.rpm ..
      cd ..

    fi


  SHELL

end
