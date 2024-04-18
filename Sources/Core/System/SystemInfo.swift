#if os(Linux) || os(FreeBSD) || os(Android)
import class Foundation.FileHandle
#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif
#elseif os(Windows)
import WinSDK
#elseif canImport(Darwin)
import Darwin
#else
#error("The Core utilities module was unable to identify your C library.")
#endif

/// https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Utilities.swift
public enum SystemInfo {
 /// A utility function that returns an estimate of the number of *logical*
 /// cores
 /// on the system available for use.
 ///
 /// On Linux the value returned will take account of cgroup or cpuset
 /// restrictions.
 /// The result will be rounded up to the nearest whole number where fractional
 /// CPUs have been assigned.
 ///
 /// - returns: The logical core count on the system.
 public static var coreCount: Int {
  #if os(Windows)
  var dwLength: DWORD = 0
  _ = GetLogicalProcessorInformation(nil, &dwLength)

  let alignment: Int =
   MemoryLayout<SYSTEM_LOGICAL_PROCESSOR_INFORMATION>.alignment
  let pBuffer =
   UnsafeMutableRawPointer.allocate(
    byteCount: Int(dwLength),
    alignment: alignment
   )
  defer {
   pBuffer.deallocate()
  }

  let dwSLPICount =
   Int(dwLength) / MemoryLayout<SYSTEM_LOGICAL_PROCESSOR_INFORMATION>.stride
  let pSLPI: UnsafeMutablePointer<SYSTEM_LOGICAL_PROCESSOR_INFORMATION> =
   pBuffer.bindMemory(
    to: SYSTEM_LOGICAL_PROCESSOR_INFORMATION.self,
    capacity: dwSLPICount
   )

  let bResult: Bool = GetLogicalProcessorInformation(pSLPI, &dwLength)
  precondition(bResult, "GetLogicalProcessorInformation: \(GetLastError())")

  return UnsafeBufferPointer<SYSTEM_LOGICAL_PROCESSOR_INFORMATION>(
   start: pSLPI,
   count: dwSLPICount
  )
  .filter { $0.Relationship == RelationProcessorCore }
  .map(\.ProcessorMask.nonzeroBitCount)
  .reduce(0, +)
  #elseif os(Linux) || os(Android)
  if let quota2 = Linux.coreCountCgroup2Restriction() {
   return quota2
  } else if let quota = Linux.coreCountCgroup1Restriction() {
   return quota
  } else if let cpusetCount = Linux.coreCount(cpuset: Linux.cpuSetPath) {
   return cpusetCount
  } else {
   return sysconf(CInt(_SC_NPROCESSORS_ONLN))
  }
  #else
  return sysconf(CInt(_SC_NPROCESSORS_ONLN))
  #endif
 }
}

// MARK: - Linux / Android Variables
#if os(Linux) || os(Android)
enum Linux {
 static let cfsQuotaPath = "/sys/fs/cgroup/cpu/cpu.cfs_quota_us"
 static let cfsPeriodPath = "/sys/fs/cgroup/cpu/cpu.cfs_period_us"
 static let cpuSetPath = "/sys/fs/cgroup/cpuset/cpuset.cpus"
 static let cfsCpuMaxPath = "/sys/fs/cgroup/cpu.max"

 private static func firstLineOfFile(path: String) -> String? {
  guard let file = fopen(path, "r") else {
   return nil
  }

  defer { fclose(file) }

  var line = ""
  repeat {
   var buf = [CChar](repeating: 0, count: 1024)
   errno = 0
   if fgets(&buf, Int32(buf.count), file) == nil {
    if ferror(file) != 0 {
     perror(nil)
    }
    return nil
   }
   line += String(cString: buf)
  } while line.lastIndex(of: "\n") == nil
  return line
 }

 private static func countCoreIDs(cores: Substring) -> Int {
  let ids = cores.split(separator: "-", maxSplits: 1)
  guard
   let first = ids.first.flatMap({ Int($0, radix: 10) }),
   let last = ids.last.flatMap({ Int($0, radix: 10) }),
   last >= first
  else {
   preconditionFailure("cpuset format is incorrect")
  }
  return 1 + last - first
 }

 static func coreCount(cpuset cpusetPath: String) -> Int? {
  guard
   let cpuset = firstLineOfFile(path: cpusetPath)?
    .split(separator: ","), !cpuset.isEmpty
  else {
   return nil
  }
  return cpuset.map(countCoreIDs).reduce(0, +)
 }

 /// Get the available core count according to cgroup1 restrictions.
 /// Round up to the next whole number.
 static func coreCountCgroup1Restriction(
  quota quotaPath: String = Linux.cfsQuotaPath,
  period periodPath: String = Linux.cfsPeriodPath
 ) -> Int? {
  guard
   let quotaLine = firstLineOfFile(path: quotaPath),
   let quota = Int(quotaLine),
   quota > 0
  else {
   return nil
  }
  guard
   let periodLine = firstLineOfFile(path: periodPath),
   let period = Int(periodLine),
   period > 0
  else {
   return nil
  }
  return (quota - 1 + period) /
   period // always round up if fractional CPU quota requested
 }

 /// Get the available core count according to cgroup2 restrictions.
 /// Round up to the next whole number.
 static func coreCountCgroup2Restriction(
  cpuMaxPath: String = Linux
   .cfsCpuMaxPath
 ) -> Int? {
  guard
   let maxDetails = firstLineOfFile(path: cpuMaxPath),
   let spaceIndex = maxDetails.firstIndex(of: " "),
   let quota = Int(maxDetails[maxDetails.startIndex ..< spaceIndex]),
   let period =
   Int(maxDetails[maxDetails.index(after: spaceIndex) ..< maxDetails.endIndex])
  else {
   return nil
  }
  return (quota - 1 + period) /
   period // always round up if fractional CPU quota requested
 }
}
#endif
