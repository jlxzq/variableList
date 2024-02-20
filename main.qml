// main.qml

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import FluentUI 1.0
import FileObject 1.0

ApplicationWindow {
    width: 1200
    height: 600
    id: root
    visible: true
    title: qsTr("VariableList")

    JTableView {
        id: j_table_view
        anchors.fill: parent
        // title: "VariableList"
        checkbox: true
        dataSource: loadData(1, 10)
        funs: [insertRow, appendRow, deleteRow, exportFile, importFile, retain, allMonitor]
        coms: ["插入行", "添加行", "删除行", "导出文件", "文件导入"]

        property var dataTypeList: ["BOOL", "BYTE", "SINT", "USINT", "INT", "UINT", "DINT", "UDINT", "REAL", "LREAL", "DWORD", "WORD", "STRING", "WSTRING", "TIME", "DATE", "TIME OF DAY", "DATE AND TIME", "LINT", "CHAR"];
        property var variableLists: ["变量表1", "变量表2", "变量表3", "变量表4", "变量表5", "变量表6", "变量表7", "变量表8", "变量表9", "变量表10"];
        property var scopeList: ["Global", "Local", "Input", "Output", "InOut", "IO", "M"];
        property var typeList: ["Global", "Type", "Program", "Function", "FunctionBlock", "IO", "M", "User", "System"]
        property var selectedIndexList: []
        property var tableModel

        //变量作用域
        Component {
            id: com_scope
            FluComboBox {
                anchors.fill: parent
                focus: true
                currentIndex: display
                editable: true
                model: ["Global", "Local", "Input", "Output", "InOut", "IO", "M"]
                Component.onCompleted: {
                    currentIndex = ["Global", "Local", "Input", "Output", "InOut", "IO", "M"].findIndex((element) => element === Number(display))
                    selectAll()
                }
                onCommit: {
                    display = editText
                    tableView.closeEditor()
                }
            }
        }

        //文件分类
        Component {
            id: com_type
            FluComboBox {
                anchors.fill: parent
                focus: true
                currentIndex: display
                editable: true
                model: ["Global", "Type", "Program", "Function", "FunctionBlock", "IO", "M", "User", "System"]
                Component.onCompleted: {
                    currentIndex = ["Global", "Type", "Program", "Function", "FunctionBlock", "IO", "M", "User", "System"].findIndex((element) => element === Number(display))
                    selectAll()
                }
                onCommit: {
                    display = editText
                    tableView.closeEditor()
                }
            }
        }

        //数据类型
        Component {
            id: com_data_type
            FluComboBox {
                anchors.fill: parent
                focus: true
                currentIndex: display
                editable: true
                model: ["BOOL", "BYTE", "SINT", "USINT", "INT", "UINT", "DINT", "UDINT", "REAL", "LREAL", "DWORD", "WORD", "STRING", "WSTRING", "TIME", "DATE", "TIME OF DAY", "DATE AND TIME", "LINT", "CHAR"]
                Component.onCompleted: {
                    currentIndex = ["BOOL", "BYTE", "SINT", "USINT", "INT", "UINT", "DINT", "UDINT", "REAL", "LREAL", "DWORD", "WORD", "STRING", "WSTRING", "TIME", "DATE", "TIME OF DAY", "DATE AND TIME", "LINT", "CHAR"].findIndex((element) => element === Number(display))
                    selectAll()
                }
                onCommit: {
                    display = editText
                    tableView.closeEditor()
                }
            }
        }

        //变量表
        Component {
            id: com_variable_list
            FluComboBox {
                anchors.fill: parent
                focus: true
                currentIndex: display
                editable: true
                model: ["变量表1", "变量表2", "变量表3", "变量表4", "变量表5", "变量表6", "变量表7", "变量表8", "变量表9", "变量表10"]
                Component.onCompleted: {
                    currentIndex = ["变量表1", "变量表2", "变量表3", "变量表4", "变量表5", "变量表6", "变量表7", "变量表8", "变量表9", "变量表10"].findIndex((element) => element === Number(display))
                    selectAll()
                }
                onCommit: {
                    display = editText
                    tableView.closeEditor()
                }
            }
        }

        //是否是常量
        Component {
            id: com_const_checkbox
            Item {
                FluCheckBox {
                    anchors.centerIn: parent
                    checked: true === options.checked
                    enableAnimation: false
                    clickListener: function () {
                        var obj = tableModel.getRow(row)
                        obj.isConstant = j_table_view.setCheckBox(com_const_checkbox, !options.checked)
                        tableModel.setRow(row, obj)
                    }
                }
            }
        }

        //是否是OPC特有项目
        Component {
            id: com_opc_checkbox
            Item {
                FluCheckBox {
                    anchors.centerIn: parent
                    checked: true === options.checked
                    enableAnimation: false
                    clickListener: function () {
                        var obj = tableModel.getRow(row)
                        obj.isOPC = j_table_view.setCheckBox(com_opc_checkbox, !options.checked)
                        tableModel.setRow(row, obj)
                    }
                }
            }
        }

        //是否在保持寄存器中
        Component {
            id: com_retained_checkbox
            Item {
                FluCheckBox {
                    anchors.centerIn: parent
                    checked: true === options.checked
                    enableAnimation: false
                    clickListener: function () {
                        var obj = tableModel.getRow(row)
                        obj.isRetained = j_table_view.setCheckBox(com_retained_checkbox, !options.checked)
                        tableModel.setRow(row, obj)
                    }
                }
            }
        }

        columnDataSource: [
            {
                title: 'ID',
                dataIndex: 'id',
                width: 65,
            },
            {
                title: '变量作用域',
                dataIndex: 'scope',
                editDelegate: com_scope,
            },
            {
                title: '文件名',
                dataIndex: 'owned',
            },
            {
                title: '文件分类',
                dataIndex: 'type',
                editDelegate: com_type,
                width: 150,
            },
            {
                title: '变量名称',
                dataIndex: 'name',
                width: 100,
            },
            {
                title: '数据类型',
                dataIndex: 'dataType',
                editDelegate: com_data_type,
                width: 120,
            },
            {
                title: '数据类型ID',
                dataIndex: 'dataTypeId',
            },
            {
                title: '长度',
                dataIndex: 'arrayLength',
            },
            {
                title: '地址',
                dataIndex: 'address',
            },
            {
                title: '是否是常量',
                dataIndex: 'isConstant',
            },
            {
                title: '是否是OPC特有项目',
                dataIndex: 'isOPC',
            },
            {
                title: '是否在保持寄存器中',
                dataIndex: 'isRetained',
            },
            {
                title: '注释',
                dataIndex: 'description',
            },
            {
                title: '创建时间',
                dataIndex: 'createTime',
            },
            {
                title: '上一次修改时间',
                dataIndex: 'lastModifyTime',
            },
            {
                title: '所属变量表',
                dataIndex: 'varList',
                editDelegate: com_variable_list,
            },
            {
                title: '初始值',
                dataIndex: 'initialValue',
            },
            {
                title: '变量状态',
                dataIndex: 'state',
            },
        ]

        FluInfoBar {
            id: infoBar
            root: root
        }

        // 加载数据
        function loadData(page, count) {
            function getRandomInt(arr) {
                return arr[Math.floor(Math.random() * arr.length)]
            }

            let dataSources = []
            for (let i = 0; i < count; i++) {
                dataSources.push({
                    id: (page - 1) * count + i,
                    scope: getRandomInt(scopeList),
                    owned: "文件" + (page - 1) * count + i,
                    type: getRandomInt(typeList),
                    name: "变量" + (page - 1) * count + i,
                    varList: getRandomInt(variableLists),
                    dataType: getRandomInt(dataTypeList),
                    dataTypeId: Math.floor(Math.random() * 100000),
                    arrayLength: Math.floor(Math.random() * 100),
                    address: "0x" + Math.floor(Math.random() * 100000).toString(16),
                    isConstant: j_table_view.setCheckBox(com_const_checkbox, Math.random() > 0.5),
                    isOPC: j_table_view.setCheckBox(com_opc_checkbox, Math.random() > 0.5),
                    isRetained: j_table_view.setCheckBox(com_retained_checkbox, Math.random() > 0.5),
                    description: "这是变量" + (page - 1) * count + i,
                    createTime: new Date().toLocaleString(),
                    lastModifyTime: new Date().toLocaleString(),
                    initialValue: 0,
                    state: "正常",
                    children: [],
                    Deep: 1,
                })
            }
            return dataSources
        }

        // 读取列表
        function getList() {
            const tableModel = j_table_view.getTableModelList()
            j_table_view.tableModel = tableModel
            j_table_view.selectedIndexList = [];
            for (let i = 0; i < tableModel.rowCount; i++) {
                if (tableModel.getRow(i).checkbox.options.checked) {
                    j_table_view.selectedIndexList.push(i)
                }
            }
            return tableModel
        }

        // 插入行
        function insertRow() {
            let source = getList().rows;
            if (!j_table_view.selectedIndexList.length) {
                infoBar.showWarning("请先选择要插入的行")
            } else {
                j_table_view.selectedIndexList.forEach((item, index) => {
                    source[item + index].checkbox.options.checked = false
                    source.splice(item, 0, {
                        id: source.length,
                        scope: "Global",
                        owned: "",
                        type: "Global",
                        name: "",
                        varList: "",
                        dataType: "BOOL",
                        dataTypeId: 0,
                        arrayLength: 0,
                        address: "",
                        isConstant: j_table_view.setCheckBox(com_const_checkbox, false),
                        isOPC: j_table_view.setCheckBox(com_opc_checkbox, false),
                        isRetained: j_table_view.setCheckBox(com_retained_checkbox, false),
                        description: "",
                        createTime: new Date().toLocaleString(),
                        lastModifyTime: new Date().toLocaleString(),
                        initialValue: 0,
                        state: "",
                        children: [],
                        Deep: 1,
                    })
                })
                j_table_view.updateDataSource(source)
            }
        }

        // 添加行
        function appendRow() {
            let source = getList().rows;
            source.push({
                id: source.length,
                scope: "Global",
                owned: "",
                type: "Global",
                name: "",
                varList: "",
                dataType: "BOOL",
                dataTypeId: 0,
                arrayLength: 0,
                address: "",
                isConstant: j_table_view.setCheckBox(com_const_checkbox, false),
                isOPC: j_table_view.setCheckBox(com_opc_checkbox, false),
                isRetained: j_table_view.setCheckBox(com_retained_checkbox, false),
                description: "",
                createTime: new Date().toLocaleString(),
                lastModifyTime: new Date().toLocaleString(),
                initialValue: 0,
                state: "",
                children: [],
                Deep: 1,
            })
            j_table_view.updateDataSource(source)
        }

        // 删除行
        function deleteRow() {
            let source = getList().rows;
            if (!j_table_view.selectedIndexList.length) {
                infoBar.showWarning("请先选择要删除的行")
            } else {
                source = source.filter((item, index) => {
                    return !j_table_view.selectedIndexList.includes(index)
                })
                j_table_view.updateDataSource(source)
            }
        }

        // 导出文件
        function exportFile() {
            fileExportDialog.open()
        }

        // 文件导入
        function importFile() {
            fileImportDialog.open()
        }

        // 保持
        function retain() {
            console.log("retain")
        }

        // 全部监视
        function allMonitor() {
            console.log("allMonitor")
        }
    }
    FileDialog {
        id: fileImportDialog
        title: "请选择要导入的xlsx文件"
        //限制文件类型为xlsx
        folder: shortcuts.home
        nameFilters: ["Excel files (*.xlsx)"]
        //禁止多选
        selectMultiple: false
        onAccepted: {
            fileObject.source = fileImportDialog.fileUrl
            const list = fileObject.read();
            list.map(item => {
                item.isConstant = j_table_view.setCheckBox(com_const_checkbox, item.isConstant.toLowerCase() === "true");
                item.isOPC = j_table_view.setCheckBox(com_opc_checkbox, item.isOPC.toLowerCase() === "true");
                item.isRetained = j_table_view.setCheckBox(com_retained_checkbox, item.isRetained.toLowerCase() === "true");
                return item
            })
            j_table_view.updateDataSource(list);
        }
    }
    FileDialog {
        id: fileExportDialog
        title: "请选择要导出的文件夹"
        folder: shortcuts.home
        selectFolder: true
        onAccepted: {
            if (fileExportDialog.fileUrl !== "") {
                // 生成一个默认的文件名
                const defaultFileName = "variableList.xlsx";
                // 拼接文件路径
                fileObject.source = fileExportDialog.fileUrl + "/" + defaultFileName;
                const list = j_table_view.getList().rows;
                fileObject.write(list);
            }
        }
    }
    FileObject {
        id: fileObject
    }
}
