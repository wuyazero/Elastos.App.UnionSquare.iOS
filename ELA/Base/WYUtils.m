//
/*
 * Copyright (c) 2020 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#import "WYUtils.h"
#import "MyUtil.h"

static dispatch_queue_t logQueue = nil;
static NSString *logPath = nil;
static NSDateFormatter *dateFormatter = nil;

@implementation WYUtils

+ (NSString *)getLogPath {
    NSString *rootPath = [MyUtil getRootPath];
    return [rootPath stringByAppendingPathComponent:LOG_FILE_NAME];
}

+ (BOOL)trimHead:(NSFileHandle *)file lower:(unsigned long long)lower size:(unsigned long long)size {
    // If file size is not given, calculate it
    if (!size)
    {
        [file seekToEndOfFile];
        size = file.offsetInFile;
    }

    // Calculate where we want to trim
    unsigned long long src = 0;
    if (size > lower) {
        src = size - lower;
    }

    // Move pointer
    [file seekToFileOffset:src];

    // What we are looking for
    NSData * nl = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];

    // Read some data
    NSUInteger len = 100;   // Arbitrary but small as we are just looking for the next nl

    while (src < size) {
        if (size - src < len) {
            len = size - src;
        }

        NSData *data = [file readDataOfLength:len];
        NSRange r = [data rangeOfData:nl options:0 range:NSMakeRange(0, data.length)];

        if (r.location != NSNotFound) {
            src += r.location + nl.length;
            break;
        }

        src += data.length;
    }

    if (src < size) {
        // Data destination
        unsigned long long dst = 0;

        // New buffer size - can be a bit larger
        len = 100000;

        // Now shuffle the bytes from here to the start
        while (src < size) {
            [file seekToFileOffset:src];

            if (size - src < len) {
                len = size - src;
            }

            NSData * data = [file readDataOfLength:len];

            [file seekToFileOffset:dst];
            [file writeData:data];

            dst += data.length;
            src += data.length;
        }

        // Done
        [file truncateFileAtOffset:dst];

        return YES;
    } else {
        return NO;
    }
}

@end

void WYLog(NSString *fmt, ...) {
    if (!logQueue) {
        logQueue = dispatch_queue_create("elastos.elawallet.LogQueue", NULL);
    }
    if (!logPath) {
        NSString *rootPath = [MyUtil getRootPath];
        logPath = [rootPath stringByAppendingPathComponent:LOG_FILE_NAME];
    }
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    
    @autoreleasepool {
        va_list args;
        va_start(args, fmt);
        NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args];
        va_end(args);
        NSLog(@"%@", msg);
        if (![msg hasSuffix:@"\n"]) {
            msg = [NSString stringWithFormat:@"%@\n", msg];
        }
        NSDate *currentDate = [NSDate date];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        msg = [NSString stringWithFormat:@"[%@] %@", dateString, msg];
        
        dispatch_async(logQueue, ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:logPath]) {
                [msg writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            } else {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
                [fileHandle closeFile];
            }
            
            unsigned long long fs = [[[NSFileManager defaultManager] attributesOfItemAtPath:logPath error:nil] fileSize];
            if (fs > LOG_SIZE_LIMIT) {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logPath];
                [WYUtils trimHead:fileHandle lower:LOG_SIZE_LIMIT * 0.9 size:fs];
                [fileHandle closeFile];
            }
        });
        
    }
    
}
