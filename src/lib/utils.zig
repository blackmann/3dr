const math = @import("std").math;

pub fn toRadians(deg: i32) f64 {
  return @intToFloat(f64, deg) * math.pi / 180;
}
