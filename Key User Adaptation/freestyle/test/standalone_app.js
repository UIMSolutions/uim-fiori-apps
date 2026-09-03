sap.ui.define([
	"sap/m/Shell",
	"sap/ui/core/Component",
	"sap/ui/core/ComponentContainer"
], async (Shell, Component, ComponentContainer) => {
	"use strict";

	const oComponent = await Component.create({
		name: "sap.ui.demoapps.rta.freestyle",
		id : "freestyle",
		componentData: {
			"showAdaptButton" : true
		}
	});
	new Shell({
		app: new ComponentContainer({
			height: "100%",
			component: oComponent
		})
	}).placeAt("content");
});
