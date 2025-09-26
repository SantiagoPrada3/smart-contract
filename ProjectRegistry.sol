// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ProjectRegistry - Registro simple de propuestas/proyectos
/// @author Santiago
/// @notice Permite crear y gestionar proyectos de un repositorio de innovación
/// @dev Ejemplo pedagógico. No usar en producción sin auditoría.
contract ProjectRegistry {
    /// @notice Dirección del owner del contrato
    address public owner;

    /// @notice ID siguiente para asignar al crear proyectos (empieza en 1)
    uint256 public nextId;

    /// @notice Estructura que representa un proyecto registrado
    struct Project {
        uint256 id;
        address proposer;
        string title;
        string description;
        uint256 timestamp;
        bool active;
    }

    /// @notice Mapeo de id -> Project
    mapping(uint256 => Project) public projects;

    /// @notice Evento emitido cuando se crea un proyecto
    /// @param id Identificador único del proyecto
    /// @param proposer Dirección que propone el proyecto
    /// @param title Título del proyecto
    event ProjectCreated(uint256 indexed id, address indexed proposer, string title);

    /// @notice Evento emitido cuando se activa/desactiva un proyecto
    /// @param id Identificador del proyecto
    /// @param active Estado actual (true = activo)
    event ProjectToggled(uint256 indexed id, bool active);

    /// @dev Modificador para funciones solo accesibles por owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo owner");
        _;
    }

    /// @dev Comprueba que un proyecto exista (id != 0)
    modifier exists(uint256 id) {
        require(projects[id].id != 0, "No existe");
        _;
    }

    /// @notice Constructor - establece el owner inicial
    /// @dev El owner será la cuenta que despliegue el contrato
    constructor() {
        owner = msg.sender;
        nextId = 1;
    }

    /// @notice Crea un nuevo proyecto
    /// @dev Usa `nextId` y emite `ProjectCreated`
    /// @param title Título corto del proyecto
    /// @param description Descripción extendida del proyecto
    /// @return id Identificador asignado al proyecto creado
    function createProject(string calldata title, string calldata description) external returns (uint256) {
        uint256 id = nextId++;
        projects[id] = Project({
            id: id,
            proposer: msg.sender,
            title: title,
            description: description,
            timestamp: block.timestamp,
            active: true
        });
        emit ProjectCreated(id, msg.sender, title);
        return id;
    }

    /// @notice Alterna el estado activo de un proyecto
    /// @dev Solo el owner puede cambiar el estado
    /// @param id Identificador del proyecto a actualizar
    function toggleActive(uint256 id) external onlyOwner exists(id) {
        projects[id].active = !projects[id].active;
        emit ProjectToggled(id, projects[id].active);
    }

    /// @notice Obtiene los datos completos de un proyecto
    /// @dev Retorna una tupla Project para facilitar lectura desde interfaces
    /// @param id Identificador del proyecto
    /// @return project Estructura con los campos del proyecto
    function getProject(uint256 id) external view exists(id) returns (Project memory project) {
        return projects[id];
    }

    /// @notice Transfiere la propiedad del contrato a otra cuenta
    /// @dev New owner no puede ser la dirección cero
    /// @param newOwner Dirección que será el nuevo owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "0 address");
        owner = newOwner;
    }
}
