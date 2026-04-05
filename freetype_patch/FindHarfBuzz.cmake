# Copyright 2015-2026.

#[=======================================================================[.rst:
FindHarfBuzz
------------

Finds the HarfBuzz text shaping library:

.. code-block:: cmake

  find_package(HarfBuzz [<version>] [...])

.. versionadded:: 3.7
  Debug and Release (optimized) library variants are found separately.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following :ref:`Imported Targets`:

``HarfBuzz::HarfBuzz``
  .. versionadded:: 3.10

  Target encapsulating the Freetype library usage requirements, available if
  Freetype is found.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

``HarfBuzz_FOUND``
  .. versionadded:: 3.3

  Boolean indicating whether (the requested version of) HarfBuzz was found.

``HarfBuzz_VERSION``
  .. versionadded:: 3.3

  The version of HarfBuzz found.

``HARFBUZZ_INCLUDE_DIRS``
  Include directories containing headers needed to use HarfBuzz.  

``HARFBUZZ_LIBRARIES``
  Libraries needed to link against for using HarfBuzz.

.. versionadded:: 3.7
  Debug and Release library variants are found separately.


Hints
^^^^^


This module accepts the following variables:

``HARFBUZZ_DIR``
  The user may set this environment variable to the root directory of a HarfBuzz
  installation to find HarfBuzz in non-standard locations.


Examples
^^^^^^^^

Finding HarfBuzz and linking it to a project target:

.. code-block:: cmake

  find_package(HarfBuzz)
  target_link_libraries(project_target PRIVATE HarfBuzz::HarfBuzz)
#]=======================================================================]


cmake_policy(PUSH)
cmake_policy(SET CMP0159 NEW) # file(STRINGS) with REGEX updates CMAKE_MATCH_<n>


set(HARFBUZZ_FIND_ARGS
  HINTS
    ${HARFBUZZ_DIR}
    ${HarfBuzz_DIR}
  PATHS
    ENV HARFBUZZ_DIR
    ENV HarfBuzz_DIR
    /usr/local
    /usr
    /usr/local/opt
    /opt/homebrew/opt
    $ENV{ProgramFiles}/harfbuzz
    $ENV{ProgramFiles\(x86\)}/harfbuzz
)

find_path(HARFBUZZ_INCLUDE_DIRS hb.h
  ${HARFBUZZ_FIND_ARGS}
  PATH_SUFFIXES
    include/harfbuzz
    include
    harfbuzz
)

if(NOT HARFBUZZ_LIBRARY)
  find_library(HARFBUZZ_LIBRARY_RELEASE
    NAMES
      harfbuzz
      libharfbuzz
    ${HARFBUZZ_FIND_ARGS}
    PATH_SUFFIXES
      lib
  )
  find_library(HARFBUZZ_LIBRARY_DEBUG
    NAMES
      harfbuzz
      libharfbuzz
    ${HARFBUZZ_FIND_ARGS}
    PATH_SUFFIXES
      lib
  )
  include(SelectLibraryConfigurations)
  select_library_configurations(HARFBUZZ)
else()
  # on Windows, ensure paths are in canonical format (forward slahes):
  file(TO_CMAKE_PATH "${HARFBUZZ_LIBRARY}" HARFBUZZ_LIBRARY)
endif()

unset(HARFBUZZ_FIND_ARGS)

if(HARFBUZZ_INCLUDE_DIRS)
  set(HARFBUZZ_VERSION_FILE "${HARFBUZZ_INCLUDE_DIR}/hb-version.h")

  if(EXISTS "${HARFBUZZ_VERSION_FILE}")
    unset(HarfBuzz_VERSION)
    file(STRINGS "${HARFBUZZ_VERSION_FILE}" hb_version_str
         REGEX "^#define[\t ]+HB_VERSION_STRING[\t ]+\".*\"")

    string(REGEX REPLACE "^#define[\t ]+HB_VERSION_STRING[\t ]+\"([^\"]*)\".*" "\\1"
           HarfBuzz_VERSION "${hb_version_str}")
		
    unset(hb_version_str)
  endif()
  unset(HARFBUZZ_VERSION_FILE)  
  
  set(HARFBUZZ_VERSION_STRING ${HarfBuzz_VERSION})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  HarfBuzz
  REQUIRED_VARS 
    HARFBUZZ_LIBRARY
    HARFBUZZ_INCLUDE_DIRS
  VERSION_VAR 
    HarfBuzz_VERSION
)

if(HarfBuzz_FOUND)
  set(HARFBUZZ_INCLUDE_DIR "${HARFBUZZ_INCLUDE_DIRS}")
  set(HARFBUZZ_LIBRARIES "${HARFBUZZ_LIBRARY}")
endif()


if(HarfBuzz_FOUND)
  if(NOT TARGET HarfBuzz::HarfBuzz)
    add_library(HarfBuzz::HarfBuzz UNKNOWN IMPORTED)
    set_target_properties(HarfBuzz::HarfBuzz PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${HARFBUZZ_INCLUDE_DIRS}")

    if(HARFBUZZ_LIBRARY_RELEASE)
      set_property(TARGET HarfBuzz::HarfBuzz APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(HarfBuzz::HarfBuzz PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "${HARFBUZZ_LIBRARY_RELEASE}")
    endif()

    if(HARFBUZZ_LIBRARY_DEBUG)
      set_property(TARGET HarfBuzz::HarfBuzz APPEND PROPERTY
        IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(HarfBuzz::HarfBuzz PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        IMPORTED_LOCATION_DEBUG "${HARFBUZZ_LIBRARY_DEBUG}")
    endif()

    if(NOT HARFBUZZ_LIBRARY_RELEASE AND NOT HARFBUZZ_LIBRARY_DEBUG)
      set_target_properties(HarfBuzz::HarfBuzz PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        IMPORTED_LOCATION "${HARFBUZZ_LIBRARY}")
    endif()
  endif()
endif()

cmake_policy(POP)