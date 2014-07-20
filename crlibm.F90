module crlibm

interface

  attributes(host, device) function exp_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: exp_rn
  double precision, value :: x
  end function

  attributes(host, device) function log_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: log_rn
  double precision, value :: x
  end function

  attributes(host, device) function log10_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: log10_rn
  double precision, value :: x
  end function

  attributes(host, device) function atan_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: atan_rn
  double precision, value :: x
  end function

  attributes(host, device) function tan_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: tan_rn
  double precision, value :: x
  end function

  attributes(host, device) function sin_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: sin_rn
  double precision, value :: x
  end function

  attributes(host, device) function cos_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: cos_rn
  double precision, value :: x
  end function

  attributes(host, device) function sinh_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: sinh_rn
  double precision, value :: x
  end function

  attributes(host, device) function cosh_rn(x) bind(C)
  use iso_c_binding
  implicit none
  double precision :: cosh_rn
  double precision, value :: x
  end function

end interface

end module crlibm

