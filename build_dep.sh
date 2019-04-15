# place all dependencies here
export DEPENDENCIES_DIR=/mnt/DATA/SDK/
mkdir -p ${DEPENDENCIES_DIR}
cd ${DEPENDENCIES_DIR}

# Boost
sudo apt-get install libboost-dev

# YAML
sudo apt-get install libyaml-cpp-dev

# SuiteSparse
sudo apt-get install libsuitesparse-dev

# g2o
cd ${DEPENDENCIES_DIR}
git clone https://github.com/RainerKuemmerle/g2o.git
cd g2o
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release .. -DCMAKE_INSTALL_PREFIX:PATH="/opt/g2o" 
make -j
sudo make install

# WxWidget
sudo apt-get install wx3.0-headers libwxgtk3.0-dev

# MRPT (viz only)
# NOTE the old mrpt only works with opencv earlier than 3.3.1, e.g. the opencv ships with ros kinetic 
cd ${DEPENDENCIES_DIR}
git clone https://github.com/MRPT/mrpt.git
cd mrpt
git checkout 0c3d605c3cbf5f2ffb8137089e43ebdae5a55de3
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE:STRING="Release" -DOpenCV_DIR:PATH="/opt/ros/kinetic/share/OpenCV-3.3.1-dev" -DCMAKE_INSTALL_PREFIX:PATH="/opt/mrpt" 
make -j
sudo make install