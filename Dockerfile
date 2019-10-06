FROM tiryoh/ros-melodic-desktop:latest
LABEL maintainer="Tiryoh <tiryoh@gmail.com>"

USER root
RUN sed -e "s/ubuntu ALL=(ALL) ALL/ubuntu ALL=(ALL) NOPASSWD:ALL/g" -i /etc/sudoers
RUN apt-get update && \
	apt-get install -y libopenblas-dev unzip wget ros-melodic-usb-cam && \
	rm -rf /var/lib/apt/lists/*

USER ubuntu
RUN mkdir -p /home/ubuntu/ws

# Install OpenCV 3.4.0
WORKDIR /home/ubuntu/ws
RUN wget https://github.com/opencv/opencv/archive/3.4.0.zip && \
	unzip 3.4.0.zip && \
	mkdir -p opencv-3.4.0/build && \
	cd opencv-3.4.0/build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_TIFF=ON -D WITH_TBB=ON -D BUILD_SHARED_LIBS=OFF .. && \
	make && \
	sudo make install && \
	rm -rf 3.4.0.zip opencv-3.4.0
# Install dlib 19.13
RUN wget http://dlib.net/files/dlib-19.13.tar.bz2 && \
	tar xf dlib-19.13.tar.bz2 && \
	mkdir -p dlib-19.13/build && \
	cd dlib-19.13/build && \
	cmake .. && \
	cmake --build . --config Release && \
	sudo make install && \
	sudo ldconfig && \
	cd ../../ && rm -rf dlib-19.13.tar.bz2 dlib-19.13

# Install OpenFace 2.1.0
RUN git clone https://github.com/TadasBaltrusaitis/OpenFace.git -b OpenFace_2.1.0 --depth 1 && \
	cd OpenFace && \
	bash ./download_models.sh && \
	mkdir build && \
	cd build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE CMAKE_CXX_FLAGS="-std=c++11" -D CMAKE_EXE_LINKER_FLAGS="-std=c++11" .. && \
	make && \
	sudo make install

# Install openface2_ros
WORKDIR /home/ubuntu/catkin_ws
RUN git clone https://github.com/ditoec/openface2_ros.git src/openface2_ros.git && \
	bash -c "source /opt/ros/melodic/setup.bash && catkin_make"
