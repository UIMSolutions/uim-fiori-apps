sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/f/library",
    "sap/m/MessageToast",
    "sap/m/MessageBox",
    "sap/ui/model/json/JSONModel",
    "sap/ui/export/Spreadsheet",
    "sap/ui/dom/includeScript",
  ],
  function (
    Controller,
    fLibrary,
    MessageToast,
    MessageBox,
    JSONModel,
    Spreadsheet,
    includeScript,
  ) {
    "use strict";

    var LayoutType = fLibrary.LayoutType;

    return Controller.extend(
      "ea.architecture.manager.controller.BaseMasterDetail",
      {
        onInit: function () {
          // UI State Model initialisieren
          var oUIModel = new JSONModel({
            isEditMode: false,
          });
          this.getView().setModel(oUIModel, "ui");
        },

        onListItemPress: function (oEvent) {
          this._setEditMode(false);
          var oListItem = oEvent.getParameter("listItem") || oEvent.getSource();
          var oContext = oListItem.getBindingContext();

          if (!oContext) {
            console.error("Kein BindingContext vorhanden!");
            return;
          }

          var oFCL = this.byId("fcl");
          var oDetailPage = this.byId("detailPage");

          if (oDetailPage && oFCL) {
            oDetailPage.setBindingContext(oContext);
            oContext
              .requestObject()
              .then(function () {
                oFCL.setLayout(LayoutType.TwoColumnsMidExpanded);
              })
              .catch(function (oError) {
                console.error("Fehler beim Laden der Detailsicht:", oError);
              });
          }
        },

        /* =================================================== */
        /* EDIT / SAVE / CANCEL LOGIK (OData v4 Auto-HTTP PATCH)*/
        /* =================================================== */
        onEditPress: function () {
          this._setEditMode(true);
        },

        onSavePress: function () {
            var oModel = this.getView().getModel();
            var that = this;

            // $auto anstelle von $direct verwenden
            oModel.submitBatch("$auto").then(function () {
                MessageToast.show("Änderungen erfolgreich gespeichert.");
                that._setEditMode(false);
            }).catch(function (oError) {
                MessageBox.error("Fehler beim Speichern der Daten: " + oError.message);
            });
        },

        onCancelPress: function () {
          var oDetailPage = this.byId("detailPage");
          var oContext = oDetailPage.getBindingContext();

          if (oContext && oContext.hasPendingChanges()) {
            oContext.resetChanges();
          }
          this._setEditMode(false);
          MessageToast.show("Änderungen verworfen.");
        },

        _setEditMode: function (bEdit) {
          this.getView().getModel("ui").setProperty("/isEditMode", bEdit);
          this.byId("btnEdit").setVisible(!bEdit);
          this.byId("btnSave").setVisible(bEdit);
          this.byId("btnCancel").setVisible(bEdit);
          this.byId("detailForm").setEditable(bEdit);
        },

        /* =================================================== */
        /* DELETE LOGIK (OData v4 Context.delete)               */
        /* =================================================== */
        onDeletePress: function () {
          var oDetailPage = this.byId("detailPage");
          var oContext = oDetailPage.getBindingContext();

          if (!oContext) {
            MessageToast.show("Kein Datensatz zum Löschen ausgewählt.");
            return;
          }

          var sId = oContext.getProperty("ID");
          var sName = oContext.getProperty("Name");
          var that = this;

          MessageBox.confirm(
            "Möchten Sie den Grundbaustein '" +
              sName +
              "' (" +
              sId +
              ") wirklich löschen?",
            {
              title: "Datensatz löschen",
              actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
              emphasizedAction: MessageBox.Action.DELETE,
              onClose: function (sAction) {
                if (sAction === MessageBox.Action.DELETE) {
                  oContext
                    .delete()
                    .then(function () {
                      MessageToast.show("Grundbaustein erfolgreich gelöscht.");
                      that._setEditMode(false);
                      that.byId("fcl").setLayout(LayoutType.OneColumn);
                    })
                    .catch(function (oError) {
                      MessageBox.error(
                        "Fehler beim Löschen: " + oError.message,
                      );
                    });
                }
              },
            },
          );
        },

        /* =================================================== */
        /* PRINT LOGIK                                         */
        /* =================================================== */
        onPrintPress: function () {
          var oDetailPage = this.byId("detailPage");
          var oDomRef = oDetailPage.getDomRef();

          if (!oDomRef) {
            MessageToast.show("Druckbereich konnte nicht ermittelt werden.");
            return;
          }

          var oWindow = window.open("", "_blank", "width=800,height=900");
          oWindow.document.write(
            "<html><head><title>Druckansicht - Grundbaustein</title>",
          );
          oWindow.document.write(
            "<link rel='stylesheet' href='https://ui5.sap.com/resources/sap/ui/core/themes/sap_horizon/library.css' type='text/css' />",
          );
          oWindow.document.write(
            "<style>body { font-family: Arial, sans-serif; padding: 20px; } @media print { .no-print { display: none; } }</style>",
          );
          oWindow.document.write("</head><body>");
          oWindow.document.write(oDomRef.innerHTML);
          oWindow.document.write("</body></html>");
          oWindow.document.close();

          setTimeout(function () {
            oWindow.focus();
            oWindow.print();
            oWindow.close();
          }, 500);
        },

        onDependencyPress: function (oEvent) {
          var oItem = oEvent.getSource();
          var oDependencyContext = oItem.getBindingContext();
          var sTargetId = oDependencyContext.getProperty("ID");

          if (!sTargetId) return;

          var oModel = this.getView().getModel();
          var oDetailPage = this.byId("detailPage");
          var oFCL = this.byId("fcl");
          var oMasterList = this.byId("masterList");

          var sPath = "/BaseBlocks('" + sTargetId + "')";
          var oTargetContext = oModel.bindContext(sPath).getBoundContext();

          oDetailPage.setBindingContext(oTargetContext);

          if (oMasterList) {
            var aItems = oMasterList.getItems();
            aItems.forEach(function (oListItem) {
              var oCtx = oListItem.getBindingContext();
              if (oCtx && oCtx.getProperty("ID") === sTargetId) {
                oMasterList.setSelectedItem(oListItem);
              }
            });
          }

          oTargetContext
            .requestObject()
            .then(function () {
              if (oFCL) {
                oFCL.setLayout(LayoutType.TwoColumnsMidExpanded);
              }
              MessageToast.show("Gewechselt zu: " + sTargetId);
            })
            .catch(function (oError) {
              console.error("Fehler beim Laden der Abhängigkeit:", oError);
            });
        },

        onExportExcelPress: function () {
          var oDetailPage = this.byId("detailPage");
          var oContext = oDetailPage.getBindingContext();

          if (!oContext) {
            MessageToast.show("Kein Datensatz ausgewählt.");
            return;
          }

          // Aktuelle Daten des Kontextes holen
          var oData = oContext.getObject();

          // Spalten-Definition für das Excel-Sheet
          var aColumns = [
            { label: "ID", property: "ID", type: "string" },
            { label: "Name", property: "Name", type: "string" },
            {
              label: "Verantwortlich",
              property: "Responsible",
              type: "string",
            },
            { label: "Version", property: "Version", type: "string" },
            { label: "Datum", property: "Date", type: "string" },
            { label: "Beschreibung", property: "Description", type: "string" },
          ];

          var oSettings = {
            workbook: {
              columns: aColumns,
              context: {
                sheetName: "Grundbaustein " + (oData.ID || ""),
              },
            },
            dataSource: [oData], // Übergabe der Objektdaten als Array
            fileName: "Grundbaustein_" + (oData.ID || "Export") + ".xlsx",
          };

          var oSheet = new Spreadsheet(oSettings);
          oSheet
            .build()
            .then(function () {
              MessageToast.show("Excel-Datei erfolgreich generiert.");
            })
            .finally(function () {
              oSheet.destroy();
            });
        },

        onExportWordPress: function () {
          var oDetailPage = this.byId("detailPage");
          var oContext = oDetailPage.getBindingContext();

          if (!oContext) {
            MessageToast.show("Kein Datensatz ausgewählt.");
            return;
          }

          var oData = oContext.getObject();

          // HTML-Template für das Word-Dokument erzeugen
          var sHtmlContent = `
    <html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
    <head><meta charset='utf-8'><title>Grundbaustein Export</title></head>
    <body style="font-family: Arial, sans-serif; margin: 20px;">
      <h1 style="color: #0070f2;">Grundbaustein: ${oData.Name || ""}</h1>
      <hr />
      <h3>Stammdaten</h3>
      <table border="1" cellspacing="0" cellpadding="5" style="border-collapse: collapse; width: 100%;">
        <tr><td><strong>ID</strong></td><td>${oData.ID || ""}</td></tr>
        <tr><td><strong>Name</strong></td><td>${oData.Name || ""}</td></tr>
        <tr><td><strong>Verantwortlich</strong></td><td>${oData.Responsible || ""}</td></tr>
        <tr><td><strong>Version</strong></td><td>${oData.Version || ""}</td></tr>
        <tr><td><strong>Datum</strong></td><td>${oData.Date || ""}</td></tr>
        <tr><td><strong>Beschreibung</strong></td><td>${oData.Description || ""}</td></tr>
      </table>
    </body>
    </html>
  `;

          // Data-Blob für den MS Word Download erstellen
          var blob = new Blob(["\ufeff" + sHtmlContent], {
            type: "application/msword",
          });

          var sFileName = "Grundbaustein_" + (oData.ID || "Export") + ".doc";

          // Download ausführen
          if (navigator.msSaveOrOpenBlob) {
            navigator.msSaveOrOpenBlob(blob, sFileName);
          } else {
            var elem = window.document.createElement("a");
            elem.href = window.URL.createObjectURL(blob);
            elem.download = sFileName;
            document.body.appendChild(elem);
            elem.click();
            document.body.removeChild(elem);
          }

          MessageToast.show("Word-Dokument wird heruntergeladen.");
        },

        /* =================================================== */
        /* DOCX EXPORT (mit korrigierter includeScript-Logik) */
        /* =================================================== */
        onExportDocxPress: function () {
          var oDetailPage = this.byId("detailPage");
          var oContext = oDetailPage.getBindingContext();

          if (!oContext) {
            MessageToast.show("Kein Datensatz ausgewählt.");
            return;
          }

          var oData = oContext.getObject();
          var that = this;

          // Hilfsfunktion: Wandelt includeScript Callbacks in ein Promise um
          var loadScriptPromise = function (sUrl, sId) {
            return new Promise(function (resolve, reject) {
              includeScript(sUrl, sId, resolve, reject);
            });
          };

          // Pfade zu den Scripts (ggf. Namespace anpassen)
          var sFileSaverUrl = sap.ui.require.toUrl(
            "ea/architecture/manager/thirdparty/FileSaver.js",
          );
          var sDocxUrl = sap.ui.require.toUrl(
            "ea/architecture/manager/thirdparty/docx.js",
          );

          // 1. Sequentielles Laden über Promises
          loadScriptPromise(sFileSaverUrl, "fileSaverScript")
            .then(function () {
              return loadScriptPromise(sDocxUrl, "docxScript");
            })
            .then(function () {
              // 2. Verfügbarkeit prüfen
              var docxLib = window.docx;

              if (!docxLib) {
                throw new Error(
                  "docx.js wurde geladen, ist aber im 'window'-Objekt nicht auffindbar.",
                );
              }

              // 3. Dokument-Struktur aufbauen
              var Document = docxLib.Document;
              var Packer = docxLib.Packer;
              var Paragraph = docxLib.Paragraph;
              var TextRun = docxLib.TextRun;
              var Table = docxLib.Table;
              var TableRow = docxLib.TableRow;
              var TableCell = docxLib.TableCell;
              var HeadingLevel = docxLib.HeadingLevel;
              var WidthType = docxLib.WidthType;

              var doc = new Document({
                sections: [
                  {
                    properties: {},
                    children: [
                      new Paragraph({
                        text: "Grundbaustein: " + (oData.Name || ""),
                        heading: HeadingLevel.HEADING_1,
                        spacing: { after: 200 },
                      }),
                      new Table({
                        width: { size: 100, type: WidthType.PERCENTAGE },
                        rows: [
                          that._createDocxRow(
                            "ID",
                            oData.ID,
                            Paragraph,
                            TextRun,
                            TableRow,
                            TableCell,
                          ),
                          that._createDocxRow(
                            "Name",
                            oData.Name,
                            Paragraph,
                            TextRun,
                            TableRow,
                            TableCell,
                          ),
                          that._createDocxRow(
                            "Verantwortlich",
                            oData.Responsible,
                            Paragraph,
                            TextRun,
                            TableRow,
                            TableCell,
                          ),
                          that._createDocxRow(
                            "Version",
                            oData.Version,
                            Paragraph,
                            TextRun,
                            TableRow,
                            TableCell,
                          ),
                          that._createDocxRow(
                            "Datum",
                            oData.Date,
                            Paragraph,
                            TextRun,
                            TableRow,
                            TableCell,
                          ),
                          that._createDocxRow(
                            "Beschreibung",
                            oData.Description,
                            Paragraph,
                            TextRun,
                            TableRow,
                            TableCell,
                          ),
                        ],
                      }),
                    ],
                  },
                ],
              });

              // 4. DOCX generieren
              return Packer.toBlob(doc);
            })
            .then(function (blob) {
              var sFileName =
                "Grundbaustein_" + (oData.ID || "Export") + ".docx";

              if (typeof window.saveAs !== "undefined") {
                window.saveAs(blob, sFileName);
              } else {
                var a = document.createElement("a");
                a.href = URL.createObjectURL(blob);
                a.download = sFileName;
                a.click();
              }

              MessageToast.show("Word-Dokument (.docx) erfolgreich erstellt.");
            })
            .catch(function (oError) {
              MessageBox.error(
                "Fehler beim Erstellen des DOCX-Dokuments: " +
                  (oError.message || oError),
              );
            });
        },

        _createDocxRow: function (
          sLabel,
          sValue,
          Paragraph,
          TextRun,
          TableRow,
          TableCell,
        ) {
          return new TableRow({
            children: [
              new TableCell({
                children: [
                  new Paragraph({
                    children: [new TextRun({ text: sLabel, bold: true })],
                  }),
                ],
              }),
              new TableCell({
                children: [
                  new Paragraph({
                    children: [new TextRun({ text: sValue || "" })],
                  }),
                ],
              }),
            ],
          });
        },

        formatCriticalityState: function (sCriticality) {
          switch (sCriticality) {
            case "High":
              return "Error";
            case "Medium":
              return "Warning";
            case "Low":
              return "Success";
            default:
              return "None";
          }
        },

        onNavHome: function () {
          this.getOwnerComponent().getRouter().navTo("home");
        },
      },
    );
  },
);
