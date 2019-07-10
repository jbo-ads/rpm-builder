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
    export PREFIX=i4d
    export INSTALL_DIR=/opt/${PREFIX}


    #########################################
    #  ECW
    #

    ###  Placement dans le dossier partagé
    cd /vagrant

    if [ ! -f ${PREFIX}-ecw-*.x86_64.rpm ] ; then

      ###  Préparation du dossier d'installation
      rm -rf ${INSTALL_DIR}
      mkdir -p ${INSTALL_DIR}

      ###  Récupération des librairies et leurs interfaces
      ecwzip="erdas-ecw-sdk-5.3.0-linux.zip"
      if [ ! -f ${ecwzip} ]
      then
        printf "\nErreur:\n" >&2
        printf "La version 5.3.0 de la librairie ECW (${ecwzip})" >&2
        printf " est nécessaire.\nMerci de la récupérer avant de" >&2
        printf " relancer la procédure.\n \n" >&2
        exit 1
      fi
      if [ ! -d ecw ] ; then
        test -f ERDAS_ECWJP2_SDK-5.3.0.bin || unzip -qq ${ecwzip}
        chmod +x ERDAS_ECWJP2_SDK-5.3.0.bin
        ln -s /usr/bin/cat more
        export PATH=.:$PATH
        printf "1\nyes\n" | ./ERDAS_ECWJP2_SDK-5.3.0.bin
        rsync -a $HOME/hexagon/ERDAS-ECW_JPEG_2000_SDK-5.3.0/Desktop_Read-Only/ ./ecw
        rm -rf $HOME/hexagon ./more
      fi

      ###  Installation des librairies et ressources
      cp -HR ecw/redistributable/x64 ${INSTALL_DIR}/lib
      cp -HR ecw/{etc,include} ${INSTALL_DIR}
      mkdir -p ${INSTALL_DIR}/share/doc/ecw
      cp ecw/ERDAS_ECW_JPEG2000_SDK.pdf ecw/eula.txt ${INSTALL_DIR}/share/doc/ecw
      cp -HR ecw/apidoc ${INSTALL_DIR}/share/doc/ecw

      ###  Réglage du RPATH
      cd ${INSTALL_DIR}/lib
      patchelf --set-rpath '$ORIGIN' libNCSEcw.so.5.3.0

      ###  Création du RPM
      cd /vagrant
      FICVER=${INSTALL_DIR}/include/ECWJP2BuildNumber.h
      MAJOR=$(awk '/NCS_ECWJP2_VER_MAJOR /{print $NF}' ${FICVER})
      MINOR=$(awk '/NCS_ECWJP2_VER_MINOR /{print $NF}' ${FICVER})
      PATCH=$(awk '/NCS_ECWJP2_VER_SERVICE /{print $NF}' ${FICVER})
      rm -rf build
      mkdir build
      cd build
      cmake3 -DNAME=${PREFIX}-ecw \
             -DVERSION="${MAJOR}.${MINOR}.${PATCH}" \
             -DRELEASE=1 \
             -DINSTALL_DIR=${INSTALL_DIR} \
             -DDIRS="lib;etc;include;share" \
             ..
      cpack3 -G RPM
      mv *.rpm ..
      cd ..

    fi


    #########################################
    #  Kakadu
    #

    ###  Placement dans le dossier partagé
    cd /vagrant

    if [ ! -f ${PREFIX}-kdu-*.x86_64.rpm ] ; then

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
      sed -i 's/^INCLUDE_AVX2/# INCLUDE_AVX2/' $(find . -name Makefile-Linux-x86-64-gcc)
      sed -i 's/-m64/-m64 -fPIC/' apps/make/Makefile-Linux-x86-64-gcc

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
      cmake3 -DNAME=${PREFIX}-kdu \
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

    ###  Placement dans le dossier partagé
    cd /vagrant

    if [ ! -f ${PREFIX}-proj-*.x86_64.rpm ] ; then

      ###  Préparation du dossier d'installation
      rm -rf ${INSTALL_DIR}
      mkdir -p ${INSTALL_DIR}

      ###  Récupération des sources
      test -d PROJ || git clone https://github.com/OSGeo/PROJ.git
      cd PROJ
      git checkout 5.2.0

      ###  Compilation et installation
      test -f configure || ./autogen.sh
      test -f Makefile || ./configure --prefix=${INSTALL_DIR}
      make
      make install

      ###  Réglage du RPATH
      cd ${INSTALL_DIR}/lib
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
      cmake3 -DNAME=${PREFIX}-proj \
             -DVERSION="${MAJOR}.${MINOR}.${PATCH}" \
             -DRELEASE=1 \
             -DINSTALL_DIR=${INSTALL_DIR} \
             -DDIRS="lib;bin;include;share" \
             ..
      cpack3 -G RPM
      mv *.rpm ..
      cd ..

    fi


    #########################################
    #  SQLite
    #

    ###  Placement dans le dossier partagé
    cd /vagrant

    if [ ! -f ${PREFIX}-sqlite3-*.x86_64.rpm ] ; then

      ###  Préparation du dossier d'installation
      rm -rf ${INSTALL_DIR}
      mkdir -p ${INSTALL_DIR}/{lib,bin,include}

      ###  Récupération des sources
      sqlzip="sqlite-amalgamation-3270200.zip"
      test -f ${sqlzip} \
        || curl -O https://www.sqlite.org/2019/${sqlzip}
      test -d ${sqlzip%.zip} || unzip -qq ${sqlzip}
      cd ${sqlzip%.zip}

      ###  Compilation
      gcc shell.c sqlite3.c -lpthread -ldl -o sqlite3
      gcc -c sqlite3.c -o sqlite3-static.o
      ar rcs libsqlite3.a sqlite3-static.o
      gcc -c -fPIC sqlite3.c -o sqlite3.o
      gcc -shared sqlite3.o -lpthread -ldl -o libsqlite3.so

      ### Installation
      cp libsqlite3.a libsqlite3.so ${INSTALL_DIR}/lib
      cp sqlite3 ${INSTALL_DIR}/bin
      cp sqlite3.h sqlite3ext.h ${INSTALL_DIR}/include

      ###  Réglage du RPATH
      cd ${INSTALL_DIR}/lib
      patchelf --set-rpath '$ORIGIN' libsqlite3.so
      for exe in ../bin/* ; do
        patchelf --set-rpath '$ORIGIN/../lib' ${exe}
      done

      ###  Création du RPM
      cd /vagrant
      FICVER=${INSTALL_DIR}/include/sqlite3.h
      MAJOR=$(awk -F'[".]' '/SQLITE_VERSION /{print $2}' ${FICVER})
      MINOR=$(awk -F'[".]' '/SQLITE_VERSION /{print $3}' ${FICVER})
      PATCH=$(awk -F'[".]' '/SQLITE_VERSION /{print $4}' ${FICVER})
      rm -rf build
      mkdir build
      cd build
      cmake3 -DNAME=${PREFIX}-sqlite3 \
             -DVERSION="${MAJOR}.${MINOR}.${PATCH}" \
             -DRELEASE=1 \
             -DINSTALL_DIR=${INSTALL_DIR} \
             -DDIRS="lib;bin;include" \
             ..
      cpack3 -G RPM
      mv *.rpm ..
      cd ..

    fi


    #########################################
    #  Expat
    #

    ###  Placement dans le dossier partagé
    cd /vagrant

    if [ ! -f ${PREFIX}-expat-*.x86_64.rpm ] ; then

      ###  Préparation du dossier d'installation
      rm -rf ${INSTALL_DIR}
      mkdir -p ${INSTALL_DIR}

      ###  Récupération des sources
      test -d libexpat || git clone https://github.com/libexpat/libexpat.git
      cd libexpat/expat
      git checkout R_2_2_6

      ###  Compilation
      ./buildconf.sh
      ./configure --prefix=${INSTALL_DIR} --without-xmlwf
      make

      ###  Installation
      make install

      ###  Réglage du RPATH
      cd ${INSTALL_DIR}/lib
      patchelf --set-rpath '$ORIGIN' libexpat.so.1.6.8

      ###  Création du RPM
      cd /vagrant
      FICVER=${INSTALL_DIR}/include/expat.h
      MAJOR=$(awk '/XML_MAJOR_VERSION /{print $NF}' ${FICVER})
      MINOR=$(awk '/XML_MINOR_VERSION /{print $NF}' ${FICVER})
      PATCH=$(awk '/XML_MICRO_VERSION /{print $NF}' ${FICVER})
      rm -rf build
      mkdir build
      cd build
      cmake3 -DNAME=${PREFIX}-expat \
             -DVERSION="${MAJOR}.${MINOR}.${PATCH}" \
             -DRELEASE=1 \
             -DINSTALL_DIR=${INSTALL_DIR} \
             -DDIRS="lib;include;share" \
             ..
      cpack3 -G RPM
      mv *.rpm ..
      cd ..
    fi


    #########################################
    #  GDAL
    #      C'est le gros morceau: les paquets
    #  précédents n'avaient aucune dépendance
    #  alors que  GDAL dépend de ces paquets.
    #      Pour la compilation, il est nécés-
    #  saire que GDAL les localise. Pour cela
    #  ils sont installés provisoirement dans
    #  /usr/local. Plus tard lors de l'exécu-
    #  tion ils seront placés à l'emplacement
    #  prévu ${INSTALL_DIR}, tout comme GDAL.
    #

    ###  Placement dans le dossier partagé
    cd /vagrant

    if [ ! -f ${PREFIX}-gdal-*.x86_64.rpm ] ; then

      ###  Préparation du dossier d'installation
      rm -rf ${INSTALL_DIR}
      mkdir -p ${INSTALL_DIR}

      ###  Installation provisoire des dépendances dans /usr/local
      TEMP_INSTALL=/usr/local
      rpm -ivh --prefix=${TEMP_INSTALL} ${PREFIX}-ecw-5.3.0-1.x86_64.rpm
      rpm -ivh --prefix=${TEMP_INSTALL} ${PREFIX}-kdu-7.10.2-1.x86_64.rpm
      rpm -ivh --prefix=${TEMP_INSTALL} ${PREFIX}-proj-5.2.0-1.x86_64.rpm
      rpm -ivh --prefix=${TEMP_INSTALL} ${PREFIX}-sqlite3-3.27.2-1.x86_64.rpm
      rpm -ivh --prefix=${TEMP_INSTALL} ${PREFIX}-expat-2.2.6-1.x86_64.rpm

      ###  Récupération des sources
      test -d gdal || git clone https://github.com/OSGeo/gdal.git
      cd gdal/gdal
      git checkout decf4b1 # Première révision de la branche 2.4 qui
                           # corrige un bug de "Content-Type" dans le
                           # driver ElasticSearch (correction utile
                           # pour MapServer). À remplacer dès que
                           # possible par "v2.4.2".

      ###  Préparation des sources pour l'intégration de Kakadu
      sed -i '12,$s/^/### /' frmts/jp2kak/jp2kak.lst

      ###  Compilation
      ./autogen.sh
      ./configure --prefix=${INSTALL_DIR} --disable-rpath \
                  --with-libtiff=internal \
                  --with-geotiff=internal \
                  --with-jpeg=internal \
                  --with-ecw=/vagrant/ecw \
                  --with-expat=${TEMP_INSTALL} \
                  --with-sqlite3=${TEMP_INSTALL} \
                  --with-proj=${TEMP_INSTALL} \
                  --with-kakadu=/vagrant/${kduzip%.zip}
      make

      ###  Installation

    fi


  SHELL

end