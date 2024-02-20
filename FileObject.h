#ifndef FILEOBJECT_H
#define FILEOBJECT_H

#include <QObject>
#include <QtXlsx>

class FileObject : public QObject {
Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)

public:
    explicit FileObject(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList read();

    Q_INVOKABLE bool write(const QVariantList &dataList);

    void setSource(const QString &source) { m_source = source; }

    QString source() const { return m_source; }

    void initializeHeader(); // 添加一个初始化表头的函数

signals:

    void sourceChanged(const QString &source);

private:
    QString m_source;
    QVector<QPair<QString, QString>> headerVector;
};

#endif // FILEOBJECT_H
