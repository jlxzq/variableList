cmake_minimum_required(VERSION 3.5)
project(variableList)

# 设置C++标准
set(CMAKE_CXX_STANDARD 20)

# 开启自动MOC、RCC和UIC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 设置QXlsx路径
set(QXLSX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/QXlsx")

# 查找并导入Qt5模块
find_package(Qt5 COMPONENTS Quick Core Gui Widgets REQUIRED)

# 添加QXlsx库
add_library(QXlsx STATIC IMPORTED)
set_target_properties(QXlsx PROPERTIES IMPORTED_LOCATION "${QXLSX_DIR}/lib/libQXlsx.a")
target_include_directories(QXlsx INTERFACE "${QXLSX_DIR}/include")

# 定义可执行文件及其源文件
add_executable(variableList
        main.cpp
        variabletable.cpp
        fileobject.cpp
)

# 包含头文件路径
target_include_directories(variableList PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# 将资源文件添加到可执行文件中
target_sources(variableList PRIVATE qml.qrc)

# 链接Qt5库
target_link_libraries(variableList
        Qt5::Quick
        Qt5::Core
        Qt5::Gui
        Qt5::Widgets
        QXlsx
)
