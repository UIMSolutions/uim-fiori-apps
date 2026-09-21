/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.myname.ports.messaging;

/// Messaging ports define the interfaces for communication between different parts of the application or with external systems.
/// They abstract the details of the messaging infrastructure, allowing the application to remain decoupled from specific implementations.
/// By using messaging ports, developers can easily swap out messaging systems without affecting the application logic.
/// Example: A messaging port might define methods for publishing events, without specifying the underlying message broker.
/// Example: A messaging port might define methods for subscribing to events, abstracting the details of the message delivery mechanism.
/// Example: A messaging port might define methods for sending commands, ensuring that the application logic remains decoupled from the messaging infrastructure.