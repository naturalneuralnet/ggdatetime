#include "tpdate.hpp"

dso::TwoPartDate
dso::TwoPartDateUTC::operator-(const dso::TwoPartDateUTC &d) const noexcept {
  int days = imjd() - d.imjd();
  double sec = seconds() - d.seconds();
  if (!days) {
    /*return dso::TwoPartDate(days, sec);*/
    ;
  } else {
    int dat1 = dso::dat(modified_julian_day(imjd()));
    int dat2 = dso::dat(modified_julian_day(d.imjd()));
    sec += (dat1 - dat2);
  }
  return TwoPartDate(days, sec);
}
