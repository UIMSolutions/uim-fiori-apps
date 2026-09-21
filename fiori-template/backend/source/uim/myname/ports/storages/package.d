/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.myname.ports.storages;

/// Storage ports define the interfaces for data persistence within the application.
/// They abstract the underlying storage mechanisms, allowing the application to remain decoupled from specific storage implementations.
/// By using storage ports, developers can easily swap out storage solutions without affecting the application logic.
/// Example: A storage port might define methods for saving and retrieving user data, without specifying the underlying database technology.
/// Example: A storage port might define methods for managing files, abstracting the details of the file system or cloud storage integration.
/// Example: A storage port might define methods for caching data, ensuring that the application logic remains decoupled from the caching infrastructure.