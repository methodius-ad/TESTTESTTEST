FROM openjdk:8-jdk

# Install-time-only environment variables
ARG ANDROID_COMPILE_SDK="30"
ARG ANDROID_BUILD_TOOLS="30.0.2"
# Android SDK tools 26.1.1

ENV ANDROID_SDK_ZIP commandlinetools-linux-6609375_latest.zip
ENV ANDROID_SDK_ZIP_URL https://dl.google.com/android/repository/$ANDROID_SDK_ZIP

ENV GRADLE_ZIP gradle-6.5-bin.zip
ENV GRADLE_ZIP_URL https://services.gradle.org/distributions/$GRADLE_ZIP

ENV REPO_OS_OVERRIDE "linux"
# Persistent environment variables
ENV ANDROID_HOME "/opt/android"
ENV ANDROID_SDK_ROOT "/opt/android"

ENV PATH $PATH:$ANDROID_SDK_ROOT/tools/bin
ENV PATH $PATH:$ANDROID_SDK_ROOT/platform-tools
#ENV PATH "${PATH}:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV PATH $PATH:/opt/gradle/gradle-6.5/bin




# Install Android-required packages
RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget unzip lib32stdc++6 lib32z1
## Install requirements
RUN dpkg --add-architecture i386
RUN rm -rf /var/lib/apt/lists/* && apt-get update && apt-get install ca-certificates curl gnupg2 software-properties-common git unzip file apt-utils lxc apt-transport-https -y
RUN apt-get install libc6:i386 libncurses5:i386 -y
RUN apt-get install libstdc++6:i386 zlib1g:i386 -y

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \

          org.label-schema.name="Jenkins-Android-Docker" \

          org.label-schema.description="Docker image for Jenkins with Android " \

          org.label-schema.vcs-ref=$VCS_REF \

          org.label-schema.vcs-url="https://github.com/WindSekirun/Jenkins-Android-Docker" \

          org.label-schema.vendor="WindSekirun" \

          org.label-schema.version=$VERSION \

          org.label-schema.schema-version="1.0"

USER root

# ------------------------------------------------------
# --- Install Android SDKs and other build packages
# ------------------------------------------------------

RUN mkdir /root/.android
RUN touch /root/.android/repositories.cfg

RUN mkdir $ANDROID_HOME
ADD $ANDROID_SDK_ZIP_URL /opt/android/
RUN unzip -q /opt/android/$ANDROID_SDK_ZIP -d $ANDROID_SDK_ROOT && rm /opt/android/$ANDROID_SDK_ZIP

## Install Android SDK into Image
RUN mkdir /opt/gradle
ADD $GRADLE_ZIP_URL /opt/gradle
RUN ls /opt/gradle/
RUN unzip /opt/gradle/$GRADLE_ZIP -d /opt/gradle


# To get a full list of available artifacts: sdkmanager --list

RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools"

# Build tools
RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;${ANDROID_BUILD_TOOLS}"

RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;30.0.3"

# SDKs
RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-${ANDROID_COMPILE_SDK}"

# Extras
RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "extras;android;m2repository"
RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "extras;google;m2repository"
RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "extras;google;google_play_services"

# Final update
RUN echo y | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update

# Install jq, xmlstarlet and protobuf compiler for release parsing
RUN apt-get --quiet install --yes jq
RUN apt-get --quiet install --yes protobuf-compiler
RUN apt-get --quiet install --yes xmlstarlet

# Install bc for floating point ops and comparisons
RUN apt-get --quiet install --yes bc

# Install tree for CI machine debugging
RUN apt-get --quiet install --yes tree
# Cleaning
RUN apt-get clean