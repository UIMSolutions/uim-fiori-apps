sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/json/JSONModel",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast",
  "sap/m/MessageBox"
], function (Controller, JSONModel, Filter, FilterOperator, MessageToast, MessageBox) {
  "use strict";

  return Controller.extend("cad.controller.App", {
    onInit: function () {
      this._canvas = null;
      this._ctx = null;
      this._isDrawing = false;
      this._tool = "pen";
      this._strokes = [];
      this._activeStroke = null;

      var oVM = new JSONModel({
        current: {
          id: "",
          name: "",
          project: "",
          drawingType: "",
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
      this._canvas = document.getElementById("cadCanvas");
      if (!this._canvas) {
        return;
      }

      this._ctx = this._canvas.getContext("2d");
      this._ctx.lineCap = "round";
      this._ctx.lineJoin = "round";

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
      this._strokes = [];
      this._activeStroke = null;
      this._redraw();
      MessageToast.show("Canvas cleared");
    },

    _onPointerDown: function (oEvent) {
      if (!this._ctx) {
        return;
      }

      this._isDrawing = true;
      var stroke = {
        tool: this._tool,
        color: this.byId("colorInput").getValue() || "#0B3D91",
        width: parseInt(this.byId("widthInput").getValue(), 10) || 2,
        points: [{ x: oEvent.offsetX, y: oEvent.offsetY }]
      };
      this._activeStroke = stroke;
      this._strokes.push(stroke);
    },

    _onPointerMove: function (oEvent) {
      if (!this._isDrawing || !this._activeStroke) {
        return;
      }

      this._activeStroke.points.push({ x: oEvent.offsetX, y: oEvent.offsetY });
      this._redraw();
    },

    _onPointerUp: function () {
      this._isDrawing = false;
      this._activeStroke = null;
    },

    _redraw: function () {
      if (!this._ctx || !this._canvas) {
        return;
      }

      this._ctx.clearRect(0, 0, this._canvas.width, this._canvas.height);

      this._strokes.forEach(function (stroke) {
        if (!stroke.points.length) {
          return;
        }

        this._ctx.strokeStyle = stroke.color;
        this._ctx.lineWidth = stroke.width;

        if (stroke.tool === "rect" && stroke.points.length > 1) {
          var p1 = stroke.points[0];
          var p2 = stroke.points[stroke.points.length - 1];
          this._ctx.strokeRect(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
          return;
        }

        if (stroke.tool === "line" && stroke.points.length > 1) {
          var l1 = stroke.points[0];
          var l2 = stroke.points[stroke.points.length - 1];
          this._ctx.beginPath();
          this._ctx.moveTo(l1.x, l1.y);
          this._ctx.lineTo(l2.x, l2.y);
          this._ctx.stroke();
          return;
        }

        this._ctx.beginPath();
        this._ctx.moveTo(stroke.points[0].x, stroke.points[0].y);
        for (var i = 1; i < stroke.points.length; i++) {
          this._ctx.lineTo(stroke.points[i].x, stroke.points[i].y);
        }
        this._ctx.stroke();
      }.bind(this));
    },

    onCreateDrawing: function () {
      this.getView().getModel("vm").setProperty("/current", {
        id: "",
        name: "",
        project: "",
        drawingType: "",
        description: ""
      });
      this._strokes = [];
      this._redraw();
    },

    onSaveDrawing: function () {
      var oCurrent = this.getView().getModel("vm").getProperty("/current");
      if (!oCurrent.name || !oCurrent.project || !oCurrent.drawingType) {
        MessageBox.error("Name, Project and Type are required.");
        return;
      }

      var oPayload = {
        ID: oCurrent.id || "",
        Name: oCurrent.name,
        Project: oCurrent.project,
        DrawingType: oCurrent.drawingType,
        Description: oCurrent.description || "",
        DataJson: JSON.stringify({ strokes: this._strokes })
      };

      var oModel = this.getView().getModel();
      if (!oCurrent.id) {
        var oListBinding = oModel.bindList("/Drawings");
        var oCreated = oListBinding.create(oPayload);
        oCreated.created().then(function () {
          MessageToast.show("Drawing created");
          this.byId("drawingList").getBinding("items").refresh();
        }.bind(this)).catch(function (oErr) {
          MessageBox.error("Create failed: " + (oErr.message || "Unknown error"));
        });
        return;
      }

      var oCtx = this._getSelectedContext();
      if (!oCtx) {
        MessageBox.error("Select a drawing to update.");
        return;
      }

      oCtx.setProperty("Name", oPayload.Name);
      oCtx.setProperty("Project", oPayload.Project);
      oCtx.setProperty("DrawingType", oPayload.DrawingType);
      oCtx.setProperty("Description", oPayload.Description);
      oCtx.setProperty("DataJson", oPayload.DataJson);
      oCtx.setProperty("UpdatedAt", new Date().toISOString());

      oModel.submitBatch("$auto").then(function () {
        MessageToast.show("Drawing updated");
      }).catch(function (oErr) {
        MessageBox.error("Update failed: " + (oErr.message || "Unknown error"));
      });
    },

    onDeleteDrawing: function () {
      var oCtx = this._getSelectedContext();
      if (!oCtx) {
        MessageToast.show("Select one drawing first");
        return;
      }

      MessageBox.confirm("Delete drawing " + oCtx.getObject().Name + "?", {
        actions: [MessageBox.Action.DELETE, MessageBox.Action.CANCEL],
        emphasizedAction: MessageBox.Action.DELETE,
        onClose: function (sAction) {
          if (sAction !== MessageBox.Action.DELETE) {
            return;
          }
          oCtx.delete("$auto").then(function () {
            MessageToast.show("Drawing deleted");
            this.onCreateDrawing();
          }.bind(this)).catch(function (oErr) {
            MessageBox.error("Delete failed: " + (oErr.message || "Unknown error"));
          });
        }.bind(this)
      });
    },

    onDrawingSelect: function (oEvent) {
      var oCtx = oEvent.getParameter("listItem").getBindingContext();
      var oData = oCtx.getObject();
      this.getView().getModel("vm").setProperty("/current", {
        id: oData.ID,
        name: oData.Name,
        project: oData.Project,
        drawingType: oData.DrawingType,
        description: oData.Description
      });

      try {
        var oParsed = JSON.parse(oData.DataJson || "{\"strokes\":[]}");
        this._strokes = oParsed.strokes || [];
      } catch (e) {
        this._strokes = [];
      }
      this._redraw();
    },

    onDisplayJson: function () {
      MessageBox.information(JSON.stringify({ strokes: this._strokes }, null, 2));
    },

    onSearch: function (oEvent) {
      var sValue = oEvent.getParameter("newValue") || "";
      var oBinding = this.byId("drawingList").getBinding("items");

      if (!sValue) {
        oBinding.filter([]);
        return;
      }

      oBinding.filter([
        new Filter({
          filters: [
            new Filter("Name", FilterOperator.Contains, sValue),
            new Filter("Project", FilterOperator.Contains, sValue),
            new Filter("DrawingType", FilterOperator.Contains, sValue)
          ],
          and: false
        })
      ]);
    },

    _getSelectedContext: function () {
      var oItem = this.byId("drawingList").getSelectedItem();
      return oItem ? oItem.getBindingContext() : null;
    }
  });
});
