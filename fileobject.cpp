#include "fileobject.h"
#include <QFileInfo>
#include <QColor>
#include "xlsxdocument.h"

FileObject::FileObject(QObject *parent) : QObject(parent) {
    initializeHeader();
}

void FileObject::initializeHeader() {
    headerVector = {
            {QStringLiteral("id"),             QStringLiteral("ID")},
            {QStringLiteral("scope"),          QStringLiteral("变量作用域")},
            {QStringLiteral("owned"),          QStringLiteral("文件名")},
            {QStringLiteral("type"),           QStringLiteral("文件分类")},
            {QStringLiteral("name"),           QStringLiteral("变量名称")},
            {QStringLiteral("dataType"),       QStringLiteral("数据类型")},
            {QStringLiteral("dataTypeId"),     QStringLiteral("数据类型ID")},
            {QStringLiteral("arrayLength"),    QStringLiteral("长度")},
            {QStringLiteral("address"),        QStringLiteral("地址")},
            {QStringLiteral("isConstant"),     QStringLiteral("是否是常量")},
            {QStringLiteral("isOPC"),          QStringLiteral("是否是OPC特有项目")},
            {QStringLiteral("isRetained"),     QStringLiteral("是否在保持寄存器中")},
            {QStringLiteral("description"),    QStringLiteral("注释")},
            {QStringLiteral("createTime"),     QStringLiteral("创建时间")},
            {QStringLiteral("lastModifyTime"), QStringLiteral("上一次修改时间")},
            {QStringLiteral("varList"),        QStringLiteral("所属变量表")},
            {QStringLiteral("initialValue"),   QStringLiteral("初始值")},
            {QStringLiteral("state"),          QStringLiteral("变量状态")}
    };
}

QVariantList FileObject::read() {
    m_source = m_source.mid(8);
    QXlsx::Document xlsx(m_source);
    QVariantList dataList;

    int rowCount = xlsx.dimension().rowCount();
    int colCount = xlsx.dimension().columnCount();

    QStringList headerList;
    for (int col = 1; col <= colCount; ++col) {
        QString header = xlsx.read(1, col).toString();
        for (const auto &pair : headerVector) {
            if (pair.second == header) {
                headerList.append(pair.first);
                break;
            }
        }
    }

    // 从第二行开始读取数据
    for (int row = 2; row <= rowCount; ++row) {
        QVariantMap rowData;
        for (int col = 1; col <= colCount; ++col) {
            QString value = xlsx.read(row, col).toString();
            rowData[headerList[col - 1]] = value;
        }
        dataList.append(rowData);
    }
    return dataList;
}

bool FileObject::write(const QVariantList &dataList) {
    m_source = m_source.mid(8);
    QFileInfo fileInfo(m_source);
    QString basePath = fileInfo.path();
    QString baseName = fileInfo.baseName();
    QString suffix = fileInfo.suffix();

    int count = 1;
    QString newFileName = m_source;
    while(QFile::exists(newFileName)){
        newFileName = QString("%1/%2_%3.%4").arg(basePath).arg(baseName).arg(count).arg(suffix);
        count++;
    }

    QXlsx::Document xlsx(newFileName);

    // 表头样式
    QXlsx::Format headerFormat;
    headerFormat.setFontBold(true);
    headerFormat.setFontSize(14);
    headerFormat.setHorizontalAlignment(QXlsx::Format::AlignHCenter);
    headerFormat.setVerticalAlignment(QXlsx::Format::AlignVCenter);
    headerFormat.setPatternBackgroundColor(QColor(0, 0, 0));
    headerFormat.setFontColor(QColor(255, 255, 255));

    // 写入表头数据
    int col = 1;
    for (const auto &pair: headerVector) {
        xlsx.write(1, col, pair.second, headerFormat); // 写入标题
        col++;
    }

    // 写入表格样式
    QXlsx::Format cellFormat;
    cellFormat.setHorizontalAlignment(QXlsx::Format::AlignHCenter);
    cellFormat.setVerticalAlignment(QXlsx::Format::AlignVCenter);
    cellFormat.setPatternBackgroundColor(QColor(255, 255, 255));
    cellFormat.setFontColor(QColor(0, 0, 0));
    cellFormat.setFontSize(12);

    int row = 2; // 从第2行开始写入变量数据

    // 写入变量数据
    for (const QVariant &var: dataList) {
        QVariantMap varMap = var.toMap();
        col = 1; // 从第1列开始写入
        for (const auto &pair: headerVector) {
            // 如果变量数据中包含该列的键，则写入变量数据中对应的值；否则写入空字符串
            if (varMap.contains(pair.first)) {
                if (pair.first == "isConstant" || pair.first == "isOPC" || pair.first == "isRetained") {
                    QVariantMap nestedMap = varMap.value(pair.first).toMap();
                    bool checked = nestedMap.value("options").toMap().value("checked").toBool();
                    xlsx.write(row, col, checked ? "TRUE" : "FALSE");
                } else {
                    xlsx.write(row, col, varMap.value(pair.first).toString());
                }
            } else {
                xlsx.write(row, col, QString()); // 写入空字符串
            }
            col++;
        }
        row++; // 移动到下一行，准备写入下一个变量的数据
    }

    // 保存xlsx文件
    xlsx.save();
    return true;
}
