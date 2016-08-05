#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

/// Substitute for CFAbsoluteTime which does not seem to be available on Linux.
public typealias AbsoluteTime = Double

/// Substitute for CFAbsoluteTimeGetCurrent() which does not seem to be available on Linux.
private func AbsoluteTimeGetCurrent() -> AbsoluteTime {
  var atime = timeval()             // initialize C struct
  let _ = gettimeofday(&atime,nil)  // will return 0
  return AbsoluteTime(atime.tv_sec) // s + µs
  + AbsoluteTime(atime.tv_usec)/AbsoluteTime(1_000_000.0)
}

public typealias UtileTimes = (user:Double,system:Double,absolute:AbsoluteTime)

private func ticksPerSecond() -> Double {
  return Double(sysconf(Int32(_SC_CLK_TCK)))
}

private func UtileTimesGetCurrent() -> UtileTimes {
  var ptime = tms()
  let _ = times(&ptime)

  return (
    user:Double(ptime.tms_utime)/ticksPerSecond(),
    system:Double(ptime.tms_stime)/ticksPerSecond(),
    absolute: AbsoluteTimeGetCurrent()
  )
}

private func -(lhs:UtileTimes, rhs:UtileTimes) -> UtileTimes {
  return (
    user:lhs.user-rhs.user,
    system:lhs.system-rhs.system,
    absolute:lhs.absolute-rhs.absolute
  )
}

/// Measure the absolute runtime of a code block.
/// Usage: `let (result,runtime) = measure { *code to measure* }`
public func utileMeasure<R>(f:()->R) -> (R, UtileTimes) {
  let start = UtileTimesGetCurrent()
  let result = f()
  let end = UtileTimesGetCurrent()
  return (result, end - start)
}
