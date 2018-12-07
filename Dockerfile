FROM debian:9

# Add source repositories
RUN echo """ \n\
  deb-src http://deb.debian.org/debian stretch main \n\
  deb-src http://deb.debian.org/debian stretch-updates main \n\
  """ >> /etc/apt/sources.list

# Update repos and install required packages for building
RUN apt-get update && apt-get install -y \
  dpkg-dev \
  sudo \
  rsync

# 1. Build
# 2. Test
# 3. Copy the build back to the host volume
CMD cd /tmp && \
  /app/davmail-build.sh && \
  mkdir /app/build && \
  rsync --no-relative -vahu /tmp/davmail_*.deb /app/build/
