//
//  canBecomeKeyWindow.m
//  twodo
//
//  Created by Daniel Lennox on 19/01/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "canBecomeKeyWindow.h"
#import <Cocoa/Cocoa.h>

@implementation NSWindow (canBecomeKeyWindow)

//This is to fix a bug with 10.7 where an NSPopover with a text field cannot be edited if its parent window won't become key
//The pragma statements disable the corresponding warning for overriding an already-implemented method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)canBecomeKeyWindow
{
    return YES;
}
#pragma clang diagnostic pop

@end