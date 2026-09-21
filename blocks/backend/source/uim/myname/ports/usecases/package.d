/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.fiori_blocks.ports.usecases;
 
/// Use case ports define the interfaces for the application's core business logic.
/// They abstract the implementation details, allowing the application to remain decoupled from specific use case implementations.
/// By using use case ports, developers can easily swap out use case implementations without affecting the application logic.
/// Example: A use case port might define methods for user registration, without specifying the underlying validation or storage mechanisms.
/// Example: A use case port might define methods for order processing, abstracting the details of payment and inventory management.
/// Example: A use case port might define methods for generating reports, ensuring that the application logic remains decoupled from the reporting infrastructure.  