#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "variabletable.h"
#include "FileObject.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv); // 使用 QGuiApplication 替换 QApplication

    // 设置组织信息
    QCoreApplication::setOrganizationName(QStringLiteral("sanxiazhikong")); // 使用 QStringLiteral 宏避免不必要的字符串拷贝
    QCoreApplication::setOrganizationDomain(QStringLiteral("sanxiazhikong.com"));

    // 注册qml类型
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    qmlRegisterType<FileObject>("FileObject", 1, 0, "FileObject");

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    // 加载指定路径的qml文件
    engine.load(url);

    return app.exec();
}
