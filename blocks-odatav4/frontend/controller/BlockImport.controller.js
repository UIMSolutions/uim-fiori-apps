sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/m/MessageBox",
    "sap/ui/dom/includeScript"
], function (Controller, MessageToast, MessageBox, includeScript) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.BlockImport", {

        onFileSelected: function (oEvent) {
            var aFiles = oEvent.getParameter("files");
            var oImportBtn = this.byId("btnImport");
            
            // Import-Button aktivieren, sobald eine Datei gewählt wurde
            oImportBtn.setEnabled(aFiles && aFiles.length > 0);
        },

        onImportExcelPress: function () {
            var oFileUploader = this.byId("excelUploader");
            var oDomRef = oFileUploader.getFocusDomRef();
            var aFiles = oDomRef && oDomRef.files ? oDomRef.files : [];

            if (aFiles.length === 0) {
                MessageBox.warning("Bitte wähle zuerst eine Excel-Datei aus.");
                return;
            }

            var oFile = aFiles[0];
            var sSelectedType = this.byId("blockTypeSelect").getSelectedKey();
            var that = this;

            // 1. xlsx.js dynamisch nachladen
            this._loadXlsxLibrary()
                .then(function () {
                    var reader = new FileReader();

                    reader.onload = function (e) {
                        try {
                            var data = new Uint8Array(e.target.result);
                            var workbook = window.XLSX.read(data, { type: "array" });

                            var sFirstSheetName = workbook.SheetNames[0];
                            var oWorksheet = workbook.Sheets[sFirstSheetName];

                            // Tabellenblatt in JSON-Array parsen
                            var aExcelData = window.XLSX.utils.sheet_to_json(oWorksheet);

                            if (!aExcelData || aExcelData.length === 0) {
                                MessageBox.warning("Die Excel-Datei enthält keine Daten.");
                                return;
                            }

                            // 2. An OData v4 / vibe.d übermitteln
                            that._sendToODataBackend(sSelectedType, aExcelData);

                        } catch (oErr) {
                            MessageBox.error("Fehler beim Lesen der Excel-Datei: " + oErr.message);
                        }
                    };

                    reader.readAsArrayBuffer(oFile);
                })
                .catch(function (oErr) {
                    MessageBox.error("Fehler beim Laden der Excel-Bibliothek (xlsx.js): " + oErr.message);
                });
        },

        _sendToODataBackend: function (sTargetEntity, aData) {
            var oModel = this.getView().getModel();
            if (!oModel) {
                MessageBox.error("OData-Modell nicht verfügbar.");
                return;
            }

            // Definiere eine eigene Group-ID für diesen Import-Batch
            var sGroupId = "excelImport_" + Date.now();
            
            // BindList für die ausgewählte Ziel-Entität anlegen
            var oListBinding = oModel.bindList("/" + sTargetEntity, null, [], [], {
                $$updateGroupId: sGroupId
            });

            var that = this;
            var iCount = 0;

            // Jeden Tabelleneintrag mappen und als POST zum Batch hinzufügen
            aData.forEach(function (row) {
                var oPayload = that._mapRowToEntity(sTargetEntity, row);
                oListBinding.create(oPayload);
                iCount++;
            });

            MessageToast.show("Übertrag " + iCount + " Datensätze an den Server...");

            // 3. Batch-Anfrage an den vibe.d / $batch Endpoint auslösen
            oModel.submitBatch(sGroupId)
                .then(function () {
                    MessageBox.success(iCount + " Datensätze wurden erfolgreich nach '" + sTargetEntity + "' importiert!");
                    that.byId("excelUploader").setValue("");
                    that.byId("btnImport").setEnabled(false);
                })
                .catch(function (oError) {
                    MessageBox.error("Fehler beim Speichern im Backend: " + (oError.message || oError));
                });
        },

        /**
         * Mappt die Rohzeilen aus Excel passend zum Schema der jeweiligen Entität
         */
        _mapRowToEntity: function (sType, row) {
            // Basisdaten für alle Bausteine
            var oEntity = {
                "ID": String(row.ID || row.id || ""),
                "Name": row.Name || row.name || "",
                "Responsible": row.Verantwortlich || row.Responsible || "",
                "Version": String(row.Version || row.version || "1.0.0"),
                "Date": row.Datum || row.Date || new Date().toISOString().split("T")[0],
                "Description": row.Beschreibung || row.Description || ""
            };

            // Typspezifische Felder ergänzen
            switch (sType) {
                case "ArchitectureBlocks":
                    oEntity.Domain = row.Domain || "";
                    oEntity.EaLayer = row.EaLayer || row["EA Layer"] || "";
                    break;
                case "SolutionBlocks":
                    oEntity.DeploymentType = row.DeploymentType || row["Deployment Type"] || "";
                    oEntity.Status = row.Status || "Draft";
                    break;
                case "InterfaceBlocks":
                    oEntity.Protocol = row.Protocol || "OData v4";
                    oEntity.SourceBlockId = String(row.SourceBlockId || "");
                    oEntity.TargetBlockId = String(row.TargetBlockId || "");
                    break;
            }

            return oEntity;
        },

        /**
         * Hilfsmethode zum Laden von xlsx.js via Promise
         */
        _loadXlsxLibrary: function () {
            return new Promise(function (resolve, reject) {
                if (window.XLSX) {
                    resolve();
                    return;
                }
                var sUrl = sap.ui.require.toUrl("ea/architecture/manager/thirdparty/xlsx.full.min.js");
                includeScript(sUrl, "xlsxScript", resolve, reject);
            });
        }

    });
});