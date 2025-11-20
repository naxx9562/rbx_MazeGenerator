# rbx_MazeGenerator

A recursive backtracking maze generation algorithm with 3D visualization. Built for RoDevs.

## Features

- **Recursive Backtracking**: Classic maze generation algorithm
- **3D Real-time Visualization**: Watch walls break as the maze forms
- **Configurable Parameters**: Adjust size, branching, dead ends, and more

### Parameters (MazeManager)
- `MAP_SIZE`: Maze dimensions (default: 30x30)
- `DEADEND_CHANCE`: Dead end probability (default: 0.15)
- `CONFUSION_CHANCE`: Creates cycles and non-optimal shortcuts between paths (default: 0.04)
- `MAX_TUNNEL_SIZE`: Longest straight section (default: 3)

## Components

- **MazeManager**: Core generation logic
- **Visual3D**: 3D wall management  
- **PathMapper**: Pathfinding & exit calculation

*Uncomment `task.wait()` in main loop for slower, real-time visualization.*