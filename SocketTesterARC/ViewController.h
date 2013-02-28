//
//  ViewController.h
//  SocketTesterARC
//
//  Created by Kyeck Philipp on 01.06.12.
//  Copyright (c) 2012 beta_interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "MessagesViewController.h"

@interface ViewController : MessagesViewController <SocketIODelegate>
{
    SocketIO *socketIO;
}

@property (strong, nonatomic) NSMutableArray *messages;

@end
