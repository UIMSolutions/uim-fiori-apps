/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.myname.ports.factories;

/// Factory ports define the interfaces for creating instances of various components within the application.
/// They abstract the instantiation logic, allowing the application to remain decoupled from specific implementations.
/// By using factory ports, developers can easily swap out component implementations without affecting the application logic.
/// Example: A factory port might define methods for creating repository instances, without specifying the underlying database technology.
/// Example: A factory port might define methods for creating service instances, abstracting the details of the service construction.
/// Example: A factory port might define methods for creating use case instances, ensuring that the application logic remains decoupled from the instantiation details.