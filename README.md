A general project structure aimed at reducing redudancy and mainstreaming common actions

# Patterns
The project uses a single source of truth with a local SwiftData store which backs the network connection. 
There is a repository pattern which acts as a central and single source of truth.  
Also the app uses a coordinator pattern to tightly control navigation.


# Testing
Network mocking is in place in order to be able to fake class.
