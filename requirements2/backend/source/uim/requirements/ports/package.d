/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.requirements.ports;

/// Ports define the interfaces through which the application interacts with external systems and infrastructure components.
/// They provide a contract that the infrastructure layer must fulfill, allowing the application to remain decoupled from specific implementations.
/// By using ports, developers can easily swap out infrastructure implementations without affecting the application logic.
/// Examples of ports include repository interfaces, external service interfaces, and messaging interfaces.
/// Example: A repository port might define methods for storing and retrieving domain entities, without specifying the underlying database technology.
/// Example: An external service port might define methods for interacting with third-party APIs, abstracting the details of the HTTP requests and responses.
/// Example: A messaging port might define methods for sending and receiving messages, allowing the application to work with different messaging systems.

public:
    import uim.requirements.ports.repositories;
    import uim.requirements.ports.externalservices;
    import uim.requirements.ports.messaging;
    import uim.requirements.ports.factories;
    import uim.requirements.ports.services;
    import uim.requirements.ports.storages;
    import uim.requirements.ports.usecases;