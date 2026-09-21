module uim.fiori_blocks.infrastructure.repositories;

/// Infrastructure repositories for the application.
/// Infrastructure repositories are responsible for managing the persistence and retrieval of domain entities from the underlying data storage.
/// They encapsulate the data access logic, providing a consistent interface for the application layer to interact with the data storage.
/// By using infrastructure repositories, developers can isolate the application layer from changes in the data storage implementation, improving maintainability and flexibility.
/// Examples of infrastructure repositories include repositories for relational databases, NoSQL databases, and external data sources.
/// Example: A repository for a relational database might handle SQL queries, transactions, and connection management, providing a simplified interface for the application layer to perform CRUD operations.
/// Example: A repository for a NoSQL database might manage document storage, indexing, and querying, allowing the application layer to interact with the database without dealing with its complexities.
/// Example: A repository for an external data source might handle API requests, data transformation, and error handling, providing a consistent interface for the application layer to access the external data.