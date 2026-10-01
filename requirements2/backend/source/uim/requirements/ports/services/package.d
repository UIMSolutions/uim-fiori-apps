/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.myname.ports.services;

/// Service ports define the interfaces for the core business services within the application.
/// They abstract the implementation details, allowing the application to remain decoupled from specific service implementations.
/// By using service ports, developers can easily swap out service implementations without affecting the application logic.
/// Example: A service port might define methods for managing user accounts, without specifying the underlying data storage or business logic.
/// Example: A service port might define methods for processing payments, abstracting the details of the payment gateway integration.
/// Example: A service port might define methods for handling notifications, ensuring that the application logic remains decoupled from the notification delivery mechanism.