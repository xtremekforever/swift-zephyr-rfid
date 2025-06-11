cmake_minimum_required(VERSION 3.29)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

# Use the armv7em-none-none-eabi target triple for Swift
set(CMAKE_Swift_COMPILER_TARGET armv7em-none-none-eabi)
# Enable "wmo" as needed by Embedded Swift
set(CMAKE_Swift_COMPILATION_MODE wholemodule)
# FIXME: Skip checking if the compiler works
set(CMAKE_Swift_COMPILER_WORKS true)

# Create a new project called "SwiftRfid" and enable "Swift" as a supported language
project(SwiftRfid Swift)

# Set global Swift compiler flags
add_compile_options(
    # Enable Embedded Swift
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-enable-experimental-feature Embedded>"

    # Enable function sections to enable dead code stripping on elf
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xfrontend -function-sections>"

    # Use software floating point operations matching GCC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -mfloat-abi=soft>"

    # Use compacted C enums matching GCC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fshort-enums>"

    # Enable data sections
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fdata-sections>"

    # Disable PIC
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fno-pic>"

    # Disable PIE
    "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -fno-pie>"
)

# Add TOOLCHAIN_C_FLAGS for toolchain to -Xcc flags
foreach(flag ${TOOLCHAIN_C_FLAGS})
    # Skip unknown flags
    string(FIND "${flag}" "-imacro" is_imacro)
    string(FIND "${flag}" "-mfp16-format" is_mfp16)
    if(NOT is_imacro EQUAL -1 OR NOT is_mfp16 EQUAL -1)
        continue()
    endif()

    add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc ${flag}>")
endforeach()

# Add definitions from Zephyr to -Xcc flags
get_target_property(ZEPHYR_DEFINES zephyr_interface INTERFACE_COMPILE_DEFINITIONS)
if(ZEPHYR_DEFINES)
    foreach(flag ${ZEPHYR_DEFINES})
        # Ignore expressions like "$<SOMETHING>"
        string(FIND "${flag}" "$<" start_of_expression)
        if(NOT start_of_expression EQUAL -1)
            continue()
        endif()

        add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-Xcc -D${flag}>")
    endforeach()
endif()

target_sources(app PRIVATE src/Stubs.c src/MFRC522.c)

# The Swift code providing "main" needs to be in an OBJECT library (instead of STATIC library) to make sure it actually gets linker.
# A STATIC library would get dropped from linking because Zephyr provides a default weak empty main definition.
add_library(app_swift OBJECT src/Main.swift src/BLE.swift src/CounterTimer.swift src/Led.swift src/MFRC522.swift)

# The code is using a String as a Dictionary key and thus require linking with libswiftUnicodeDataTables.a
# We compute the path where this file reside, taking into accout how the toolchain is referenced (Swiftly or TOOLCHAINS env variable). 
find_program(SWIFTLY "swiftly")
IF(SWIFTLY)
  execute_process(COMMAND swiftly use --print-location OUTPUT_VARIABLE toolchain_path)
  cmake_path(SET additional_lib_path NORMALIZE "${toolchain_path}/usr/lib/swift/embedded/${CMAKE_Swift_COMPILER_TARGET}")
ELSE()
  get_filename_component(compiler_bin_dir ${CMAKE_Swift_COMPILER} DIRECTORY)
  cmake_path(SET additional_lib_path NORMALIZE "${compiler_bin_dir}/../lib/swift/embedded/${CMAKE_Swift_COMPILER_TARGET}")
ENDIF()

target_link_directories(zephyr_pre0 PRIVATE "${additional_lib_path}")
target_link_libraries(zephyr_pre0
    -Wl,--no-whole-archive
    -Wl,--no-enum-size-warning
)

target_link_directories(zephyr_final PRIVATE "${additional_lib_path}")
target_link_libraries(zephyr_final
    -Wl,--no-whole-archive
    -Wl,--no-enum-size-warning
)

# Discard unused sections
zephyr_linker_sources(SECTIONS "sections.ld")

add_dependencies(app_swift syscall_list_h_target)
target_compile_options(app_swift PRIVATE
    -parse-as-library

    -Osize

    -Xfrontend -disable-stack-protector

    # FIXME: add dependency on BridgingHeader.h
    -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/src/BridgingHeader.h
)

# Copy include paths from C target to Swift target
target_include_directories(app_swift PRIVATE
    "$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>"
)

# Link the Swift target into the primary target
target_link_libraries(app PRIVATE app_swift)
