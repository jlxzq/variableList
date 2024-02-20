cmake_minimum_required(VERSION 3.5)
project(variableList)

# 设置C++标准
set(CMAKE_CXX_STANDARD 20)

# 开启自动MOC、RCC和UIC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 查找并导入Qt5模块
find_package(Qt5 COMPONENTS Quick Core Gui Widgets Xlsx REQUIRED)

# 设置Qt5库的查找路径
list(APPEND CMAKE_PREFIX_PATH "path/to/Qt/lib/cmake/Qt5")

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
        Qt5::Xlsx
)
