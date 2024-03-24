import os

/// https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Utilities.swift
public enum SystemInfo {
 /// A utility function that returns an estimate of the number of *logical* cores
 /// on the system available for use.
 ///
 /// On Linux the value returned will take account of cgroup or cpuset restrictions.
 /// The result will be rounded up to the nearest whole number where fractional CPUs have been assigned.
 ///
 /// - returns: The logical core count on the system.
 public static var coreCount: Int {
  #if os(Windows)
  var dwLength: DWORD = 0
  _ = GetLogicalProcessorInformation(nil, &dwLength)

  let alignment: Int =
   MemoryLayout<SYSTEM_LOGICAL_PROCESSOR_INFORMATION>.alignment
  let pBuffer =
   UnsafeMutableRawPointer.allocate(byteCount: Int(dwLength),
                                    alignment: alignment)
  defer {
   pBuffer.deallocate()
  }

  let dwSLPICount =
   Int(dwLength) / MemoryLayout<SYSTEM_LOGICAL_PROCESSOR_INFORMATION>.stride
  let pSLPI: UnsafeMutablePointer<SYSTEM_LOGICAL_PROCESSOR_INFORMATION> =
   pBuffer.bindMemory(to: SYSTEM_LOGICAL_PROCESSOR_INFORMATION.self,
                      capacity: dwSLPICount)

  let bResult: Bool = GetLogicalProcessorInformation(pSLPI, &dwLength)
  precondition(bResult, "GetLogicalProcessorInformation: \(GetLastError())")

  return UnsafeBufferPointer<SYSTEM_LOGICAL_PROCESSOR_INFORMATION>(start: pSLPI,
                                                                   count: dwSLPICount)
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
