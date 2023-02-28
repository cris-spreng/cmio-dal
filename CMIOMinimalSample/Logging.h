#ifndef Logging_h
#define Logging_h

#define DLog(fmt, ...) NSLog((@"CMIOMS: " fmt), ##__VA_ARGS__)
#define DLogFunc(fmt, ...) NSLog((@"CMIOMS: %s " fmt), __FUNCTION__, ##__VA_ARGS__)

#endif /* Logging_h */
