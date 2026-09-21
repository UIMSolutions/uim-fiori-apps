/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.ports.externalservices;

/// External service ports define the interfaces for interacting with third-party APIs and external systems.
/// They abstract the details of the communication protocols, allowing the application to remain decoupled from specific implementations.
/// By using external service ports, developers can easily swap out external service providers without affecting the application logic.
/// Example: An external service port might define methods for fetching data from a third-party API, without specifying the underlying HTTP requests and responses.
/// Example: An external service port might define methods for sending data to a third-party API, abstracting the details of the network communication.
/// Example: An external service port might define methods for subscribing to events from an external system, without coupling the application to the specific event delivery mechanism.