project( GF_PL_SLAM )

cmake_minimum_required(VERSION 2.7)

MESSAGE("CMake Build Type: "  ${CMAKE_BUILD_TYPE})

LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake_modules)

# set( OpenCV_DIR /opt/ros/kinetic/share/OpenCV-3.3.1-dev )
# find_package(OpenCV 3 REQUIRED)
set( OpenCV_DIR /opt/opencv3/share/OpenCV )
find_package(OpenCV 3 REQUIRED)
MESSAGE("OpenCV include dir: " ${OpenCV_INCLUDE_DIRS})

find_package(Boost    REQUIRED COMPONENTS thread system filesystem)

# set(Eigen_DIR /usr/include/eigen3 )
# find_package(Eigen3   REQUIRED)
SET( EIGEN3_INCLUDE_DIR /usr/include/eigen3 )
MESSAGE("EIGEN include dir: " ${EIGEN3_INCLUDE_DIR})

set( G2O_DIR /opt/g2o/lib/g2o/ )
find_package(G2O      REQUIRED)
MESSAGE("G2O include dir: " ${G2O_INCLUDE_DIR})
MESSAGE("G2O libraries " ${G2O_LIBRARIES})

find_package(Cholmod REQUIRED)

if(COMMAND cmake_policy)
    cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)
link_directories(${OpenCV_LIBS_DIR})
include_directories(${OpenCV2_INCLUDE_DIRS})

set(DEFAULT_HAS_MRPT ON)
set(HAS_MRPT ${DEFAULT_HAS_MRPT} CACHE BOOL "Build the PointGrey Bumblebee2 SVO application that employs the MRPT library")

SET(BUILD_SHARED_LIBS ON)
SET(CMAKE_MODULE_PATH $ENV{CMAKE_MODULE_PATH})
# SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x -O3 -mtune=native -march=native")
# SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -pthread -O3 -mtune=native -march=native")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -std=c++11  -Wl,--no-as-needed -pthread -Wall  -O3 -march=native ")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11  -Wl,--no-as-needed -pthread -Wall  -O3 -march=native")
MESSAGE(">>>>>  Compiler flags are: " ${CMAKE_CXX_FLAGS})

# MRPT library (optional, only with representation purposes)
if(HAS_MRPT)
    set(MRPT_DIR /opt/mrpt/share/mrpt )
    FIND_PACKAGE(MRPT REQUIRED base opengl gui hwdrivers)
    set(MRPT_DONT_USE_DBG_LIBS 1) #use release libraries for linking even if "Debug" CMake build
    add_definitions(-DHAS_MRPT)
endif(HAS_MRPT)
MESSAGE("MRPT libraries " ${MRPT_LIBS})

# YAML library
set(YAML_CPP_INCLUDE_DIRS /usr/include/yaml-cpp/)
set(YAML_CPP_LIBRARIES    /usr/lib/x86_64-linux-gnu/libyaml-cpp.so)
# find_library(YAML_CPP_LIBRARIES yaml-cpp)
# if(NOT YAML_CPP_LIBRARIES)
#     # If yaml-cpp not found in the system, try finding it as a user CMake-generated project
#     find_package(yaml-cpp REQUIRED)
#     include_directories(${YAML_CPP_INCLUDE_DIRS})
# endif(NOT YAML_CPP_LIBRARIES)
MESSAGE("YAML libraries " ${YAML_CPP_LIBRARIES})

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/build)
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)

# Include dirs
include_directories(
    include
    ${YAML_CPP_INCLUDE_DIRS}
    ${Eigen3_INCLUDE_DIRS}
    ${OpenCV_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${PROJECT_SOURCE_DIR}/3rdparty/DBoW2/DBoW2/
    ${PROJECT_SOURCE_DIR}/3rdparty/line_descriptor/include/
    ${G2O_INCLUDE_DIR}
    /usr/include/suitesparse # for cholmod
    )

# Set link libraries
list(APPEND LINK_LIBS
    ${YAML_CPP_LIBRARIES}
    ${OpenCV_LIBS}
    ${Boost_LIBRARIES}
    cholmod
    ${G2O_LIBRARIES}
    ${PROJECT_SOURCE_DIR}/3rdparty/DBoW2/lib/libDBoW2.so
    ${PROJECT_SOURCE_DIR}/3rdparty/line_descriptor/lib/liblinedesc.so
    )

# Set source files
if(HAS_MRPT)
    list(APPEND SOURCEFILES
        src/linespec.cpp
        src/config.cpp
        src/auxiliar.cpp
        src/pinholeStereoCamera.cpp
        src/stereoFeatures.cpp
        src/stereoFrame.cpp
        src/stereoFrameHandler.cpp
        src/mapHandler.cpp
        src/mapFeatures.cpp
        src/keyFrame.cpp
        src/voScene.cpp
        src/slamScene.cpp
        src/ORBextractor.cc
        )
else()
    list(APPEND SOURCEFILES
        src/linespec.cpp
        src/config.cpp
        src/auxiliar.cpp
        src/pinholeStereoCamera.cpp
        src/stereoFeatures.cpp
        src/stereoFrame.cpp
        src/stereoFrameHandler.cpp
        src/mapHandler.cpp
        src/mapFeatures.cpp
        src/keyFrame.cpp
        src/ORBextractor.cc
        )
endif()

# List all files (headers) contained by StVO-PL library
file(GLOB_RECURSE all_include_files RELATIVE "${CMAKE_SOURCE_DIR}" *.h *.hpp)

# Visualize the files of this directory in IDE creating an custom empty target
add_custom_target( plslam_includes DEPENDS ${all_include_files} SOURCES ${all_include_files} )

# Create StVO-PL library
add_library(plslam SHARED ${SOURCEFILES})

if(HAS_MRPT)
    target_link_libraries(plslam ${LINK_LIBS} ${MRPT_LIBS}  )
else()
    target_link_libraries(plslam ${LINK_LIBS})
endif()

# Applications [TODO: ADD VO APPLICATIONS]
if(HAS_MRPT)
    add_executable       ( plslam_dataset app/plslam_dataset.cpp )
    target_link_libraries( plslam_dataset plslam )
    add_executable       ( plstvo_dataset app/plstvo_dataset.cpp )
    target_link_libraries( plstvo_dataset plslam )
    #
    add_executable       ( plstvo_mod     app/plstvo_mod.cpp )
    target_link_libraries( plstvo_mod     plslam )
    add_executable       ( plslam_mod     app/plslam_mod.cpp )
    target_link_libraries( plslam_mod     plslam )
endif(HAS_MRPT)

# test cases
#FIND_PACKAGE( Boost REQUIRED system thread )
#INCLUDE_DIRECTORIES( ${Boost_INCLUDE_DIR} )
#MESSAGE("Boost libs: " ${Boost_LIBRARIES})

#add_executable( testCut
#    ${SOURCEFILES}
##    ./test/testCut_1.cpp
#    ./test/main.cpp
#    )
#target_link_libraries( testCut
#    ${LINK_LIBS}
#    ${GTest_LIBRARIES}
#)
