set(fortran_src
    nemsio_chgdate.f90)

if(CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel)$")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -convert big_endian")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "^(GNU)$")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fconvert=big-endian")
endif()

set(exe_name nemsio_chgdate)
add_executable(${exe_name} ${fortran_src})
target_link_libraries(
  ${exe_name}
  nemsio::nemsio bacio::bacio_4 w3nco::w3nco_d)

install(TARGETS ${exe_name} RUNTIME DESTINATION ${exec_dir})
