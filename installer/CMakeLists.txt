cmake_minimum_required(VERSION 3.21)
project(zengos-installer VERSION 0.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Quick Qml)
qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(zengos-installer src/main.cpp src/backend.cpp src/backend.h)

set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(zengos-installer
  URI ZengInstaller
  VERSION 1.0
  QML_FILES
    qml/Main.qml
    qml/Pill.qml
    qml/Choice.qml
    qml/Toggle.qml
    qml/Field.qml
    qml/Steps.qml
    qml/Theme.qml
  SOURCES
    src/backend.h
    src/backend.cpp
)

target_link_libraries(zengos-installer PRIVATE Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml)

install(TARGETS zengos-installer RUNTIME DESTINATION bin)
install(PROGRAMS backend/zeng-install-backend DESTINATION lib/zengos)
target_include_directories(zengos-installer PRIVATE src)
