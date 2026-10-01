sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/json/JSONModel",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast",
  "sap/m/MessageBox"
], function (Controller, JSONModel, Filter, FilterOperator, MessageToast, MessageBox) {
  "use strict";

  return Controller.extend("uml.controller.App", {
    onNavHome: function () {
      this.getOwnerComponent().getRouter().navTo("home");
    },

    onNavLibrary: function () {
      this.getOwnerComponent().getRouter().navTo("library");
    },

    onNavInsights: function () {
      this.getOwnerComponent().getRouter().navTo("insights");
    },

    onInit: function () {
      this._canvas = null;
      this._ctx = null;
      this._isDrawing = false;
      this._tool = "class";
      this._shapes = [];
      this._activeShape = null;

      var oVM = new JSONModel({
        current: {
          id: "",
          name: "",
          project: "",
          diagramType: "",
          description: ""
        }
      });
      this.getView().setModel(oVM, "vm");

      this.getView().addEventDelegate({
        onAfterRendering: function () {
          this._initCanvas();
        }.bind(this)
      });
    },

    _initCanvas: function () {
      this._canvas = document.getElementById("umlCanvas");
      if (!this._canvas) {
        return;
      }

      this._ctx = this._canvas.getContext("2d");
      this._ctx.lineCap = "round";
      this._ctx.lineJoin = "round";
      this._ctx.font = "13px sans-serif";

      this._canvas.onmousedown = this._onPointerDown.bind(this);
      this._canvas.onmousemove = this._onPointerMove.bind(this);
      this._canvas.onmouseup = this._onPointerUp.bind(this);
      this._canvas.onmouseleave = this._onPointerUp.bind(this);

      this._canvas.ontouchstart = function (e) {
        e.preventDefault();
        var p = e.touches[0];
        this._onPointerDown({ offsetX: p.clientX - this._canvas.getBoundingClientRect().left, offsetY: p.clientY - this._canvas.getBoundingClientRect().top });
      }.bind(this);
      this._canvas.ontouchmove = function (e) {
        e.preventDefault();
        var p = e.touches[0];
        this._onPointerMove({ offsetX: p.clientX - this._canvas.getBoundingClientRect().left, offsetY: p.clientY - this._canvas.getBoundingClientRect().top });
      }.bind(this);
      this._canvas.ontouchend = function (e) {
        e.preventDefault();
        this._onPointerUp();
      }.bind(this);

      this._redraw();
    },

    onToolChange: function (oEvent) {
      this._tool = oEvent.getSource().getSelectedKey();
    },

    onClearCanvas: function () {
      this._shapes = [];
      this._activeShape = null;
      this._redraw();
      MessageToast.show("Canvas cleared");
    },

    _onPointerDown: function (oEvent) {
      if (!this._ctx) {
        return;
      }

      this._isDrawing = true;
      this._activeShape = {
        tool: this._tool,
        color: this.byId("colorInput").getValue() || "#0A5A8F",
        width: parseInt(this.byId("widthInput").getValue(), 10) || 2,
        x1: oEvent.offsetX,
        y1: oEvent.offsetY,
        x2: oEvent.offsetX,
        y2: oEvent.offsetY,
        label: this._tool === "class" ? "Class" : this._tool === "actor" ? "Actor" : ""
      };
      this._shapes.push(this._activeShape);
    },

    _onPointerMove: function (oEvent) {
      if (!this._isDrawing || !this._activeShape) {
        return;
      }

      this._activeShape.x2 = oEvent.offsetX;
      this._activeShape.y2 = oEvent.offsetY;
      this._redraw();
    },

    _onPointerUp: function () {
      this._isDrawing = false;
      this._activeShape = null;
    },

    _drawArrowHead: function (x1, y1, x2, y2, color) {
      var headLength = 10;
      var angle = Math.atan2(y2 - y1, x2 - x1);
      this._ctx.fillStyle = color;
      this._ctx.beginPath();
      this._ctx.moveTo(x2, y2);
      this._ctx.lineTo(x2 - headLength * Math.cos(angle - Math.PI / 6), y2 - headLength * Math.sin(angle - Math.PI / 6));
      this._ctx.lineTo(x2 - headLength * Math.cos(angle + Math.PI / 6), y2 - headLength * Math.sin(angle + Math.PI / 6));
      this._ctx.closePath();
      this._ctx.fill();
    },

    _redraw: function () {
      if (!this._ctx || !this._canvas) {
        return;
      }

      this._ctx.clearRect(0, 0, this._canvas.width, this._canvas.height);

      this._shapes.forEach(function (shape) {
        this._ctx.strokeStyle = shape.color;
        this._ctx.lineWidth = shape.width;
        this._ctx.fillStyle = shape.color;

        if (shape.tool === "class") {
          var x = Math.min(shape.x1, shape.x2);
          var y = Math.min(shape.y1, shape.y2);
          var w = Math.abs(shape.x2 - shape.x1);
          var h = Math.abs(shape.y2 - shape.y1);
          this._ctx.strokeRect(x, y, w, h);
          this._ctx.beginPath();
          this._ctx.moveTo(x, y + 24);
          this._ctx.lineTo(x + w, y + 24);
          this._ctx.stroke();
          this._ctx.fillText(shape.label || "Class", x + 8, y + 16);
          return;
        }

        if (shape.tool === "actor") {
          var cx = shape.x1;
          var cy = shape.y1;
          this._ctx.beginPath();
          this._ctx.arc(cx, cy - 20, 12, 0, Math.PI * 2);
          this._ctx.stroke();
          this._ctx.beginPath();
          this._ctx.moveTo(cx, cy - 8);
          this._ctx.lineTo(cx, cy + 26);
          this._ctx.moveTo(cx - 16, cy + 2);
          this._ctx.lineTo(cx + 16, cy + 2);
          this._ctx.moveTo(cx, cy + 26);
          this._ctx.lineTo(cx - 14, cy + 46);
          this._ctx.moveTo(cx, cy + 26);
          this._ctx.lineTo(cx + 14, cy + 46);
          this._ctx.stroke();
          this._ctx.fillText("Actor", cx - 16, cy + 62);
          return;
        }

        if (shape.tool === "note") {
          var nx = Math.min(shape.x1, shape.x2);
          var ny = Math.min(shape.y1, shape.y2);
          var nw = Math.abs(shape.x2 - shape.x1);
          var nh = Math.abs(shape.y2 - shape.y1);
          this._ctx.setLineDash([5, 4]);
          this._ctx.strokeRect(nx, ny, nw, nh);
          this._ctx.setLineDash([]);
          this._ctx.fillText("Note", nx + 8, ny + 18);
          return;
        }

        this._ctx.beginPath();
        this._ctx.moveTo(shape.x1, shape.y1);
        this._ctx.lineTo(shape.x2, shape.y2);
        this._ctx.stroke();

        if (shape.tool === "arrow") {
          this._drawArrowHead(shape.x1, shape.y1, shape.x2, shape.y2, shape.color);
        }
      }.bind(this));
    },

    onCreateDiagram: function () {
      this.getView().getModel("vm").setProperty("/current", {
        id: "",
        name: "",
        project: "",
        diagramType: "",
        description: ""
      });
      this._shapes = [];
      this._redraw();
    },

    onSaveDiagram: function () {
      var oCurrent = this.getView().getModel("vm").getProperty("/current");
      if (!oCurrent.name || !oCurrent.project || !oCurrent.diagramType) {
        MessageBox.error("Name, Project and Diagram Type are required.");
        return;
      }

      var oPayload = {
        ID: oCurrent.id || "",
        Name: oCurrent.name,
        Project: oCurrent.project,
        DiagramType: oCurrent.diagramType,
        Description: oCurrent.description || "",
        DataJson: JSON.stringify({ shapes: this._shapes })
      };

      var oModel = this.getView().getModel();
      if (!oCurrent.id) {
        var oListBinding = oModel.bindList("/Diagrams");
        var oCreated = oListBinding.create(oPayload);
        oCreated.created().then(function () {
          MessageToast.show("Diagram created");
          this.byId("diagramList").getBinding("items").refresh();
        }.bind(this)).catch(function (oErr) {
          MessageBox.error("Create failed: " + (oErr.message || "Unknown error"));
        });
        return;
      }

      var oCtx = this._getSelectedContext();
      if (!oCtx) {
        MessageBox.error("Select a diagram to update.");
        return;
      }

      oCtx.setProperty("Name", oPayload.Name);
      oCtx.setProperty("Project", oPayload.Project);
      oCtx.setProperty("DiagramType", oPayload.DiagramType);
      oCtx.setProperty("Description", oPayload.Description);
      oCtx.setProperty("DataJson", oPayload.DataJson);
      oCtx.setProperty("UpdatedAt", new Date().toISOString());

      oModel.submitBatch("$auto").then(function () {
        MessageToast.show("Diagram updated");
      }).catch(function (oErr) {
        MessageBox.error("Update failed: " + (oErr.message || "Unknown error"));
      });
    },

    onDeleteDiagram: function () {
      var oCtx = this._getSelectedContext();
      if (!oCtx) {
        MessageToast.show("Select one diagram first");
        return;
      }

      MessageBox.confirm("Delete diagram " + oCtx.getObject().Name + "?", {
        actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
        emphasizedAction: MessageBox.Action.DELETE,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.DELETE) {
            return;
          }
          oCtx.delete("$auto").then(function () {
            MessageToast.show("Diagram deleted");
            this.onCreateDiagram();
          }.bind(this)).catch(function (oErr) {
            MessageBox.error("Delete failed: " + (oErr.message || "Unknown error"));
          });
        }.bind(this)
      });
    },

    onDiagramSelect: function (oEvent) {
      var oCtx = oEvent.getParameter("listItem").getBindingContext();
      var oData = oCtx.getObject();
      this.getView().getModel("vm").setProperty("/current", {
        id: oData.ID,
        name: oData.Name,
        project: oData.Project,
        diagramType: oData.DiagramType,
        description: oData.Description
      });

      try {
        var oParsed = JSON.parse(oData.DataJson || "{\"shapes\":[]}");
        this._shapes = oParsed.shapes || [];
      } catch (e) {
        this._shapes = [];
      }
      this._redraw();
    },

    onDisplayJson: function () {
      MessageBox.information(JSON.stringify({ shapes: this._shapes }, null, 2));
    },

    onSearch: function (oEvent) {
      var sValue = oEvent.getParameter("newValue") || "";
      var oBinding = this.byId("diagramList").getBinding("items");

      if (!sValue) {
        oBinding.filter([]);
        return;
      }

      oBinding.filter([
        new Filter({
          filters: [
            new Filter("Name", FilterOperator.Contains, sValue),
            new Filter("Project", FilterOperator.Contains, sValue),
            new Filter("DiagramType", FilterOperator.Contains, sValue)
          ],
          and: false
        })
      ]);
    },

    _getSelectedContext: function () {
      var oItem = this.byId("diagramList").getSelectedItem();
      return oItem ? oItem.getBindingContext() : null;
    }
  });
});
