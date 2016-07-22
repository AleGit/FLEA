#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Substitute for CFAbsoluteTime which does not seem to be available on Linux.
typealias AbsoluteTime = Double

func AbsoluteTimeGetCurrent() -> AbsoluteTime {
  var atime = timeval()             // initialize C struct
  let _ = gettimeofday(&atime,nil)  // will return 0
  return AbsoluteTime(atime.tv_sec) // s + µs
  + AbsoluteTime(atime.tv_usec)/AbsoluteTime(1_000_000.0)
}

typealias UtileTimes = (user:Double,system:Double,absolute:AbsoluteTime)

func ticksPerSecond() -> Double {
  return Double(sysconf(Int32(_SC_CLK_TCK)))
}

/// Substitute for CFAbsoluteTimeGetCurrent() which does not seem to be available on Linux.
func UtileTimesGetCurrent() -> UtileTimes {
  var ptime = tms()
  let _ = times(&ptime)

  return (
    user:Double(ptime.tms_utime)/ticksPerSecond(),
    system:Double(ptime.tms_stime)/ticksPerSecond(),
    absolute: AbsoluteTimeGetCurrent()
  )
}

func -(lhs:UtileTimes, rhs:UtileTimes) -> UtileTimes {
  return (
    user:lhs.user-rhs.user,
    system:lhs.system-rhs.system,
    absolute:lhs.absolute-rhs.absolute
  )
}

/// Measure the absolute runtime of a code block.
/// Usage: `let (result,runtime) = measure { *code to measure* }`
func measure<R>(f:()->R) -> (R, UtileTimes) {
  let start = UtileTimesGetCurrent()
  let result = f()
  let end = UtileTimesGetCurrent()
  return (result, end - start)
}

func mymeasure<R>(f:()->R) -> (R, UtileTimes) {
  let start = UtileTimesGetCurrent()
  let result = f()
  let end = UtileTimesGetCurrent()
  return (result, end - start)
}
