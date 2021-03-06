//
//  GRListingRequest.m
//  GoldRaccoon
//  v1.0.1
//
//  Created by Valentin Radu on 8/23/11.
//  Copyright 2011 Valentin Radu. All rights reserved.
//
//  Modified and/or redesigned by Lloyd Sargent to be ARC compliant.
//  Copyright 2012 Lloyd Sargent. All rights reserved.
//
//  Modified and redesigned by Alberto De Bortoli.
//  Copyright 2013 Alberto De Bortoli. All rights reserved.
//

#import "GRListingRequest.h"
#import "SVProgressHUD.h"
#import <sys/dirent.h>

@interface GRListingRequest ()

@property (nonatomic, strong) NSMutableData *receivedData;

@end

@implementation GRListingRequest

@synthesize filesInfo;
@synthesize receivedData;

- (BOOL)fileExists:(NSString *)fileNamePath
{
    NSString *fileName = [[fileNamePath lastPathComponent] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    
    for (NSDictionary *file in self.filesInfo) {
        NSString *name = [file objectForKey:(id)kCFFTPResourceName];
        if ([fileName isEqualToString:name]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)path
{
    // the path will always point to a directory, so we add the final slash to it (if there was one before escaping/standardizing, it's *gone* now)
    NSString *directoryPath = [super path];
    if (![directoryPath hasSuffix: @"/"]) {
        directoryPath = [directoryPath stringByAppendingString:@"/"];
    }
    return directoryPath;
}

- (void)start
{
    self.maximumSize = LONG_MAX;
    
    // open the read stream and check for errors calling delegate methods
    // if things fail. This encapsulates the streamInfo object and cleans up our code.
    [self.streamInfo openRead:self];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    NSData *data;
    
    switch (streamEvent) {
        case NSStreamEventOpenCompleted: {
			self.filesInfo = [NSMutableArray array];
            self.didOpenStream = YES;
            self.receivedData = [NSMutableData data];
        } break;
            
        case NSStreamEventHasBytesAvailable: {
            data = [self.streamInfo read:self];
            
            if (data) {
                [self.receivedData appendData: data];
            }
            else {
                NSLog(@"Stream opened, but failed while trying to read from it.");
                [self.streamInfo streamError:self errorCode:kGRFTPClientCantReadStream];
            }
        }
        break;
            
        case NSStreamEventHasSpaceAvailable: {
            
        } 
        break;
            
        case NSStreamEventErrorOccurred: {
            [self.streamInfo streamError:self errorCode:[GRError errorCodeWithError:[theStream streamError]]];
            NSLog(@"%@", self.error.message);
            [SVProgressHUD showInfoWithStatus:@"连接失败"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REABLEDBTN" object:nil];
        }
        break;
            
        case NSStreamEventEndEncountered: {
            NSUInteger  offset = 0;
            CFIndex     parsedBytes;
            uint8_t *bytes = (uint8_t *)[self.receivedData bytes];
            int totalbytes = [self.receivedData length];
            
            do {
                CFDictionaryRef listingEntity = NULL;
                parsedBytes = CFFTPCreateParsedResourceListing(NULL, &bytes[offset], totalbytes - offset, &listingEntity);
                if (parsedBytes > 0) {
                    if (listingEntity != NULL) {
                        
                    NSDictionary *dic=   [self entryByReencodingNameInEntry:(__bridge_transfer NSDictionary *)listingEntity encoding:NSUTF8StringEncoding];
//                        kCFFTPResourceType
                        self.filesInfo = [self.filesInfo arrayByAddingObject:dic];
//                        self.filesInfo = [self.filesInfo arrayByAddingObject:(__bridge_transfer NSDictionary *)listingEntity];
                        
//
                    }
                    offset += parsedBytes;
                }
            } while (parsedBytes > 0);
            
            [self.streamInfo streamComplete:self];
        }
        break;
        
        default:
            break;
    }
}


- (NSDictionary *)entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding
// CFFTPCreateParsedResourceListing always interprets the file name as MacRoman,
// which is clearly bogus <rdar://problem/7420589>.  This code attempts to fix
// that by converting the Unicode name back to MacRoman (to get the original bytes;
// this works because there's a lossless round trip between MacRoman and Unicode)
// and then reconverting those bytes to Unicode using the encoding provided.
{
    NSDictionary *  result;
    NSString *      name;
    NSData *        nameData;
    NSString *      newName;
    
    newName = nil;
    
    // Try to get the name, convert it back to MacRoman, and then reconvert it
    // with the preferred encoding.
    
    name = [entry objectForKey:(id) kCFFTPResourceName];
    if (name != nil) {
        assert([name isKindOfClass:[NSString class]]);
        
        nameData = [name dataUsingEncoding:NSMacOSRomanStringEncoding];
        if (nameData != nil) {
            newName = [[NSString alloc] initWithData:nameData encoding:newEncoding];
            
            if (newName == nil) {
                newName = @"文件名解码失败";
            }
        }
    }
    NSLog(@"name is %@",name);
    
    NSLog(@"newname is %@",newName);
    
    
    // If the above failed, just return the entry unmodified.  If it succeeded,
    // make a copy of the entry and replace the name with the new name that we
    // calculated.
    
    if (newName == nil) {
        assert(NO);                 // in the debug builds, if this fails, we should investigate why
        result = (NSDictionary *) entry;
    } else {
        NSMutableDictionary *   newEntry;
        
        newEntry = [entry mutableCopy];
        assert(newEntry != nil);
        
        [newEntry setObject:newName forKey:(id) kCFFTPResourceName];
        
        result = newEntry;
    }
    
    return result;
}

@end
