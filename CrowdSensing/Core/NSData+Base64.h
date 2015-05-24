//
//  NSData+Base64.h
//  Marslakok
//
//  Created by András Door on 2/21/12.
//  Copyright 2012 4D Soft Kft.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;
- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end
