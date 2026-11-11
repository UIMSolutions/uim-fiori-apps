sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/export/Spreadsheet",
    "sap/m/MessageToast",
    "sap/m/MessageBox"
], function (Controller, Spreadsheet, MessageToast, MessageBox) {
    "use strict";

    return Controller.extend("ea.architecture.manager.controller.BlockExport", {

        onExportExcelPress: function () {
            var sSelectedType = this.byId("blockTypeSelect").getSelectedKey();
            var oModel = this.getView().getModel();

            if (!oModel) {
                MessageBox.error("OData-Modell ist nicht verfügbar.");
                return;
            }

            // 1. Spaltenkonfiguration je nach Baustein-Typ ermitteln
            var aColumns = this._getColumnsForType(sSelectedType);

            // 2. Export-Einstellungen definieren
            var oSettings = {
                workbook: {
                    columns: aColumns,
                    context: {
                        sheetName: sSelectedType
                    }
                },
                dataSource: {
                    type: "OData",
                    dataUrl: oModel.sServiceUrl + "/" + sSelectedType,
                    useBatch: true, // Nutzt den $batch Endpoint im vibe.d Backend
                    headers: oModel.getHttpHeaders ? oModel.getHttpHeaders() : {}
                },
                fileName: sSelectedType + "_Export.xlsx",
                worker: false // Bei kleineren/mittleren Datenmengen stabiler
            };

            // 3. Spreadsheet-Export ausführen
            var oSheet = new Spreadsheet(oSettings);
            
            MessageToast.show("Excel-Export wird gestartet...");

            oSheet.build()
                .then(function () {
                    MessageToast.show("Export erfolgreich abgeschlossen!");
                })
                .catch(function (sError) {
                    MessageBox.error("Fehler beim Excel-Export: " + sError);
                })
                .finally(function () {
                    oSheet.destroy();
                });
        },

        /**
         * Hilfsmethode: Liefert die passenden Tabellenspalten je nach Entität
         */
        _getColumnsForType: function (sType) {
            // Gemeinsame Standard-Spalten für Bausteine
            var aCommonColumns = [
                { label: "ID", property: "ID", type: "string", width: 15 },
                { label: "Name", property: "Name", type: "string", width: 25 },
                { label: "Verantwortlich", property: "Responsible", type: "string", width: 20 },
                { label: "Version", property: "Version", type: "string", width: 10 },
                { label: "Datum", property: "Date", type: "string", width: 15 },
                { label: "Beschreibung", property: "Description", type: "string", width: 35 }
            ];

            // Typspezifische Zusatzspalten ergänzen
            switch (sType) {
                case "ArchitectureBlocks":
                    return aCommonColumns.concat([
                        { label: "Domain", property: "Domain", type: "string", width: 20 },
                        { label: "EA Layer", property: "EaLayer", type: "string", width: 15 }
                    ]);

                case "SolutionBlocks":
                    return aCommonColumns.concat([
                        { label: "Deployment Type", property: "DeploymentType", type: "string", width: 20 },
                        { label: "Status", property: "Status", type: "string", width: 15 }
                    ]);

                case "InterfaceBlocks":
                    return aCommonColumns.concat([
                        { label: "Protocol", property: "Protocol", type: "string", width: 15 }, // z.B. OData v4 / REST
                        { label: "Source Block", property: "SourceBlockId", type: "string", width: 15 },
                        { label: "Target Block", property: "TargetBlockId", type: "string", width: 15 }
                    ]);

                case "BaseBlocks":
                default:
                    return aCommonColumns;
            }
        }

    });
});