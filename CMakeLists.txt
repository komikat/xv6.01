project(mini2)
cmake_minimum_required(VERSION 3.0)

# Define MLFQ as a CMake variable
set(MLFQ 1)

# Use the variable to conditionally set compiler flags
if(MLFQ)
    add_definitions(-DMLFQ)
endif()

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/initial_xv6)

# Execute the build process (e.g., make)
execute_process(
        COMMAND make
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/initial_xv6/src
)